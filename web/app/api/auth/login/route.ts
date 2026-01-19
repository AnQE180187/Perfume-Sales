import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
    try {
        const { email, password } = await request.json();

        if (!email || !password) {
            return NextResponse.json(
                { error: 'Email and password are required' },
                { status: 400 }
            );
        }

        const supabase = createClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
        );

        // Sign in with password
        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password,
        });

        if (error) {
            return NextResponse.json({ error: error.message }, { status: error.status || 401 });
        }

        // Lấy thông tin Profile bổ sung (Role, Loyalty Points...)
        const { data: profile, error: profileError } = await supabase
            .from('profiles')
            .select(`
                *,
                user_roles (
                    roles (
                        code
                    )
                ),
                loyalty_accounts (
                    current_points
                )
            `)
            .eq('id', data.user.id)
            .single();

        if (profileError) {
            console.error('Error fetching profile:', profileError);
        }

        // Kiểm tra trạng thái tài khoản
        if (profile && profile.account_status !== 'active') {
            await supabase.auth.signOut();
            return NextResponse.json(
                { error: `Account is ${profile.account_status}. Please contact support.` },
                { status: 403 }
            );
        }

        // Flatten roles and points
        const roles = profile?.user_roles?.map((ur: any) => ur.roles?.code) || [];
        const loyalty_points = profile?.loyalty_accounts?.current_points || 0;

        return NextResponse.json({
            message: 'Login successful',
            session: data.session,
            user: {
                ...data.user,
                profile: {
                    ...profile,
                    roles: roles,
                    loyalty_points: loyalty_points
                },
            },
        });
    } catch (err: any) {
        console.error('Login API error:', err);
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
