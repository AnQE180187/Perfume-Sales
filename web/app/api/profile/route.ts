import { createClient } from '@supabase/supabase-js'
import { NextResponse } from 'next/server'

export async function PUT(request: Request) {
    try {
        const body = await request.json()
        const {
            id,
            full_name,
            phone,
            avatar_url,
            scent_preferences,
            budget_range,
            style_preferences
        } = body

        if (!id) {
            return NextResponse.json({ error: 'User ID is required' }, { status: 400 })
        }

        const supabase = createClient(
            process.env.NEXT_PUBLIC_SUPABASE_URL!,
            process.env.SUPABASE_SERVICE_ROLE_KEY!
        )

        // Build update object dynamically to only update provided fields
        const updateData: any = {
            updated_at: new Date().toISOString()
        }
        if (full_name !== undefined) updateData.full_name = full_name
        if (phone !== undefined) updateData.phone = phone
        if (avatar_url !== undefined) updateData.avatar_url = avatar_url
        if (scent_preferences !== undefined) updateData.scent_preferences = scent_preferences
        if (budget_range !== undefined) updateData.budget_range = budget_range
        if (style_preferences !== undefined) updateData.style_preferences = style_preferences

        const { data, error } = await supabase
            .from('profiles')
            .update(updateData)
            .eq('id', id)
            .select()
            .single()

        if (error) {
            return NextResponse.json({ error: error.message }, { status: 400 })
        }

        return NextResponse.json({ message: 'Profile updated successfully', profile: data })
    } catch (err: any) {
        console.error('Profile API error:', err)
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 })
    }
}
