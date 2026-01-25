import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdateProfileDto } from './dto/update-profile.dto';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  findMe(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        phone: true,
        role: true,
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
        createdAt: true,
      },
    });
  }

  updateMe(userId: string, dto: UpdateProfileDto) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        fullName: dto.fullName,
        gender: dto.gender,
        dateOfBirth: dto.dateOfBirth ? new Date(dto.dateOfBirth) : undefined,
        address: dto.address,
        city: dto.city,
        country: dto.country,
        avatarUrl: dto.avatarUrl,
        budgetMin: dto.budgetMin,
        budgetMax: dto.budgetMax,
      },
      select: {
        id: true,
        email: true,
        phone: true,
        role: true,
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
        createdAt: true,
      },
    });
  }
}
