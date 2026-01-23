import { NextResponse } from 'next/server'

const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000/api/v1';

export async function PUT(request: Request) {
    try {
        const body = await request.json()
        const {
            fullName,
            phone,
            avatarUrl,
            gender,
            dateOfBirth,
            address,
            city,
            country,
            budgetMin,
            budgetMax
        } = body

        // Get token from Authorization header
        const authHeader = request.headers.get('Authorization')
        if (!authHeader) {
            return NextResponse.json({ error: 'Unauthorized' }, { status: 401 })
        }

        // Build update object dynamically to only update provided fields
        const updateData: any = {}
        if (fullName !== undefined) updateData.fullName = fullName
        if (phone !== undefined) updateData.phone = phone
        if (avatarUrl !== undefined) updateData.avatarUrl = avatarUrl
        if (gender !== undefined) updateData.gender = gender
        if (dateOfBirth !== undefined) updateData.dateOfBirth = dateOfBirth
        if (address !== undefined) updateData.address = address
        if (city !== undefined) updateData.city = city
        if (country !== undefined) updateData.country = country
        if (budgetMin !== undefined) updateData.budgetMin = budgetMin
        if (budgetMax !== undefined) updateData.budgetMax = budgetMax

        const response = await fetch(`${API_BASE_URL}/users/me`, {
            method: 'PATCH',
            headers: {
                'Authorization': authHeader,
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(updateData),
        })

        const data = await response.json()

        if (!response.ok) {
            return NextResponse.json(
                { error: data.message || data.error || 'Update failed' },
                { status: response.status }
            )
        }

        return NextResponse.json({ message: 'Profile updated successfully', profile: data })
    } catch (err: any) {
        console.error('Profile API error:', err)
        return NextResponse.json({ error: 'Internal Server Error' }, { status: 500 })
    }
}
