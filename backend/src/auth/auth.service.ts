import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { UserRoleEnum } from '@prisma/client';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) { }

  async register(dto: RegisterDto) {
    const existing = await this.prisma.user.findFirst({
      where: { OR: [{ email: dto.email }, { phone: dto.phone ?? undefined }] },
    });
    if (existing) {
      throw new ConflictException('Email or phone already in use');
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    // Check if this is the first user
    const userCount = await this.prisma.user.count();
    const role = userCount === 0 ? UserRoleEnum.ADMIN : UserRoleEnum.CUSTOMER;

    const user = await this.prisma.user.create({
      data: {
        email: dto.email,
        phone: dto.phone,
        passwordHash,
        fullName: dto.fullName,
        role,
      },
    });

    return this.generateTokens(user.id, user.email, user.role);
  }

  async login(dto: LoginDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    if (!user || !user.passwordHash) {
      throw new UnauthorizedException('Invalid credentials');
    }

    const passwordValid = await bcrypt.compare(dto.password, user.passwordHash);
    if (!passwordValid) {
      throw new UnauthorizedException('Invalid credentials');
    }

    return this.generateTokens(user.id, user.email, user.role);
  }

  async refreshTokens(refreshToken: string) {
    try {
      const payload = await this.jwtService.verifyAsync<any>(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      });

      if (!payload?.sub || !payload?.email || !payload?.role) {
        throw new ForbiddenException('Invalid refresh token');
      }

      return this.generateTokens(payload.sub, payload.email, payload.role);
    } catch {
      throw new ForbiddenException('Invalid refresh token');
    }
  }

  async validateOAuthUser(profile: any) {
    const { email, fullName, avatarUrl, provider, providerId } = profile;

    // 1. Find or create user
    let user = await this.prisma.user.findUnique({
      where: { email },
    });

    if (!user) {
      user = await this.prisma.user.create({
        data: {
          email,
          fullName,
          avatarUrl,
          role: UserRoleEnum.CUSTOMER,
          isActive: true,
        },
      });
    } else {
      // Update avatar if it was missing or changed
      await this.prisma.user.update({
        where: { id: user.id },
        data: { avatarUrl },
      });
    }

    // 2. Find or create OAuth account
    const oauthAccount = await this.prisma.oAuthAccount.findUnique({
      where: {
        provider_providerAccountId: {
          provider,
          providerAccountId: providerId,
        },
      },
    });

    if (!oauthAccount) {
      await this.prisma.oAuthAccount.create({
        data: {
          userId: user.id,
          provider,
          providerAccountId: providerId,
        },
      });
    }

    // 3. Generate tokens
    return this.generateTokens(user.id, user.email, user.role);
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    const accessToken = await this.jwtService.signAsync(payload as any, {
      secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
      // use seconds (number) for compatibility with the JwtSignOptions type
      expiresIn:
        this.configService.get<number>('JWT_ACCESS_EXPIRES_IN') ?? 15 * 60,
    });

    const refreshToken = await this.jwtService.signAsync(payload as any, {
      secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      expiresIn:
        this.configService.get<number>('JWT_REFRESH_EXPIRES_IN') ??
        7 * 24 * 60 * 60,
    });

    return {
      accessToken,
      refreshToken,
    };
  }
}
