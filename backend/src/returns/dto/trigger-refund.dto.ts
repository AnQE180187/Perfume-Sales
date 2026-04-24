import { IsString, IsOptional, IsIn, IsNumber } from 'class-validator';

export class TriggerRefundDto {
  @IsString()
  @IsIn(['manual', 'cash', 'bank_transfer', 'gateway'])
  method: 'manual' | 'cash' | 'bank_transfer' | 'gateway';

  @IsOptional()
  @IsNumber()
  amount?: number;

  @IsOptional()
  @IsString()
  transactionId?: string; // bank transfer id if applicable

  @IsOptional()
  @IsString()
  note?: string;

  @IsOptional()
  @IsString()
  receiptImage?: string;
}
