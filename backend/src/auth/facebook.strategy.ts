import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PassportStrategy } from '@nestjs/passport';
import { Profile, Strategy } from 'passport-facebook';

@Injectable()
export class FacebookStrategy extends PassportStrategy(Strategy, 'facebook') {
    constructor(private configService: ConfigService) {
        super({
            clientID: configService.get<string>('FACEBOOK_APP_ID') || 'facebook-id',
            clientSecret: configService.get<string>('FACEBOOK_APP_SECRET') || 'facebook-secret',
            callbackURL: configService.get<string>('FACEBOOK_CALLBACK_URL') || 'http://localhost:5000/api/v1/auth/facebook/callback',
            scope: 'email',
            profileFields: ['emails', 'name', 'photos'],
        });
    }

    async validate(
        accessToken: string,
        refreshToken: string,
        profile: Profile,
        done: (err: any, user: any, info?: any) => void,
    ): Promise<any> {
        const { name, emails, photos, id } = profile;
        const user = {
            provider: 'facebook',
            providerId: id,
            email: emails?.[0]?.value || '',
            fullName: name ? `${name.givenName} ${name.familyName}` : 'Facebook User',
            avatarUrl: photos?.[0]?.value || '',
            accessToken,
        };
        done(null, user);
    }
}
