import { createClient } from '@supabase/supabase-js';
import { NextResponse } from 'next/server';

export async function POST(request: Request) {
    try {
        const { email, password, full_name, phone } = await request.json();

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

        // 1. Sign up user in Supabase Auth
        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: {
                    full_name: full_name,
                    phone: phone,
                },
            },
        });

        if (error) {
            return NextResponse.json({ error: error.message }, { status: error.status || 400 });
        }

        return NextResponse.json({
            message: 'Registration successful. Please check your email for verification.',
            user: data.user,
        });
    } catch (err: any) {
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 });
    }
}
