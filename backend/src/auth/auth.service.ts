import {
  Injectable,
  UnauthorizedException,
  ConflictException,
  ForbiddenException,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import * as bcrypt from 'bcryptjs';
import * as crypto from 'crypto';
import { PrismaService } from '../prisma/prisma.service';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { ChangePasswordDto } from './dto/change-password.dto';
import { UserRoleEnum } from '@prisma/client';

@Injectable()
export class AuthService {
  // In-memory store for reset tokens (in production, use Redis or database)
  private resetTokens = new Map<string, { email: string; expiresAt: Date }>();

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

    if (!user.isActive) {
      throw new UnauthorizedException('Account is deactivated');
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

  async forgotPassword(dto: ForgotPasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { email: dto.email },
    });

    // Don't reveal if user exists or not for security
    if (!user) {
      return {
        success: true,
        message: 'If the email exists, a reset link has been sent',
      };
    }

    // Generate reset token
    const resetToken = crypto.randomBytes(32).toString('hex');
    const expiresAt = new Date(Date.now() + 3600000); // 1 hour

    // Store token (in production, use Redis or database)
    this.resetTokens.set(resetToken, {
      email: user.email,
      expiresAt,
    });

    // TODO: Send email with reset link
    // const resetLink = `${this.configService.get('FRONTEND_URL')}/reset-password?token=${resetToken}`;
    // await this.emailService.sendPasswordReset(user.email, resetLink);

    console.log(`Password reset token for ${user.email}: ${resetToken}`);
    console.log(`Reset link: ${this.configService.get('FRONTEND_URL')}/reset-password?token=${resetToken}`);

    return {
      success: true,
      message: 'If the email exists, a reset link has been sent',
      // For development only - remove in production
      resetToken: process.env.NODE_ENV === 'development' ? resetToken : undefined,
    };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const tokenData = this.resetTokens.get(dto.token);

    if (!tokenData) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    if (new Date() > tokenData.expiresAt) {
      this.resetTokens.delete(dto.token);
      throw new BadRequestException('Reset token has expired');
    }

    const user = await this.prisma.user.findUnique({
      where: { email: tokenData.email },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, 10);

    await this.prisma.user.update({
      where: { id: user.id },
      data: { passwordHash },
    });

    // Delete used token
    this.resetTokens.delete(dto.token);

    return {
      success: true,
      message: 'Password has been reset successfully',
    };
  }

  async changePassword(userId: string, dto: ChangePasswordDto) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user || !user.passwordHash) {
      throw new NotFoundException('User not found');
    }

    const passwordValid = await bcrypt.compare(dto.oldPassword, user.passwordHash);
    if (!passwordValid) {
      throw new UnauthorizedException('Current password is incorrect');
    }

    const passwordHash = await bcrypt.hash(dto.newPassword, 10);

    await this.prisma.user.update({
      where: { id: userId },
      data: { passwordHash },
    });

    return {
      success: true,
      message: 'Password changed successfully',
    };
  }

  async validateOAuthUser(profile: {
    provider: string;
    providerId: string;
    email: string;
    fullName?: string;
    firstName?: string;
    lastName?: string;
    avatarUrl?: string;
    accessToken?: string;
  }) {
    // Check if user exists with this OAuth account
    let oauthAccount = await this.prisma.oAuthAccount.findUnique({
      where: {
        provider_providerAccountId: {
          provider: profile.provider,
          providerAccountId: profile.providerId,
        },
      },
      include: { user: true },
    });

    if (oauthAccount) {
      // Update access token
      await this.prisma.oAuthAccount.update({
        where: { id: oauthAccount.id },
        data: {
          accessToken: profile.accessToken,
        },
      });

      return this.generateTokens(
        oauthAccount.user.id,
        oauthAccount.user.email,
        oauthAccount.user.role,
      );
    }

    // Check if user exists with this email
    let user = await this.prisma.user.findUnique({
      where: { email: profile.email },
    });

    if (user) {
      // Link OAuth account to existing user
      await this.prisma.oAuthAccount.create({
        data: {
          userId: user.id,
          provider: profile.provider,
          providerAccountId: profile.providerId,
          accessToken: profile.accessToken,
        },
      });
    } else {
      // Create new user with OAuth account
      user = await this.prisma.user.create({
        data: {
          email: profile.email,
          fullName: profile.fullName || `${profile.firstName || ''} ${profile.lastName || ''}`.trim(),
          avatarUrl: profile.avatarUrl,
          role: UserRoleEnum.CUSTOMER,
          accounts: {
            create: {
              provider: profile.provider,
              providerAccountId: profile.providerId,
              accessToken: profile.accessToken,
            },
          },
        },
      });
    }

    return this.generateTokens(user.id, user.email, user.role);
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        fullName: true,
        gender: true,
        dateOfBirth: true,
        address: true,
        city: true,
        country: true,
        avatarUrl: true,
        budgetMin: true,
        budgetMax: true,
        loyaltyPoints: true,
        role: true,
        isActive: true,
        createdAt: true,
        updatedAt: true,
      },
    });

    if (!user) {
      throw new NotFoundException('User not found');
    }

    return user;
  }

  private async generateTokens(userId: string, email: string, role: string) {
    const payload = { sub: userId, email, role };

    const accessToken = await this.jwtService.signAsync(payload as any, {
      secret: this.configService.get<string>('JWT_ACCESS_SECRET'),
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
      user: {
        id: userId,
        email,
        role,
      },
    };
  }
}
