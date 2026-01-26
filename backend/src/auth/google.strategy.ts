import { PassportStrategy } from '@nestjs/passport';
import { Strategy, VerifyCallback } from 'passport-google-oauth20';
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class GoogleStrategy extends PassportStrategy(Strategy, 'google') {
    constructor(private configService: ConfigService) {
        super({
            clientID: configService.get<string>('GOOGLE_CLIENT_ID') || 'google-id',
            clientSecret: configService.get<string>('GOOGLE_CLIENT_SECRET') || 'google-secret',
            callbackURL: configService.get<string>('GOOGLE_CALLBACK_URL') || 'http://localhost:5000/api/v1/auth/google/callback',
            scope: ['email', 'profile'],
        });
    }

    async validate(
        accessToken: string,
        refreshToken: string,
        profile: any,
        done: VerifyCallback,
    ): Promise<any> {
        const { name, emails, photos, id } = profile;
        const user = {
            provider: 'google',
            providerId: id,
            email: emails?.[0]?.value || '',
            fullName: name ? `${name.givenName} ${name.familyName}` : 'Google User',
            avatarUrl: photos?.[0]?.value || '',
            accessToken,
        };
        done(null, user);
    }
}
