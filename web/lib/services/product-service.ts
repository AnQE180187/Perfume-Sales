import { supabase } from '../supabase';
import { supabaseAdmin } from '../supabaseAdmin';

export const ProductService = {
    // Get all active products with nested details
    async getProducts(filters?: { gender?: string; brand_id?: string; category_id?: string }) {
        let query = supabaseAdmin
            .from('products')
            .select(`
        *,
        brand:brands(*),
        category:categories(*),
        variants:product_variants(*),
        images:product_images(*)
      `);

        if (filters?.gender) query = query.eq('gender', filters.gender);
        if (filters?.brand_id) query = query.eq('brand_id', filters.brand_id);
        if (filters?.category_id) query = query.eq('category_id', filters.category_id);

        const { data, error } = await query.order('created_at', { ascending: false });
        if (error) throw error;
        return data;
    },

    // Get single product by slug or ID
    async getProductDetail(idOrSlug: string) {
        const isUuid = idOrSlug.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i);

        let query = supabaseAdmin
            .from('products')
            .select(`
        *,
        brand:brands(*),
        category:categories(*),
        variants:product_variants(*),
        images:product_images(*),
        reviews:reviews(
          *,
          user:profiles(full_name, avatar_url)
        )
      `);

        if (isUuid) {
            query = query.eq('id', idOrSlug);
        } else {
            query = query.eq('slug', idOrSlug);
        }

        const { data, error } = await query.single();
        if (error) throw error;
        return data;
    },

    // Semantic Search (Requires pgvector match_products function)
    async searchSemantic(queryText: string) {
        // 1. Generate embedding for query (calling AI service)
        // For demo/simulated, assume we have a helper or route
        // This part usually calls OpenAI/xAI embeddings API
        const response = await fetch('/api/ai/embed', {
            method: 'POST',
            body: JSON.stringify({ text: queryText })
        });
        const { embedding } = await response.json();

        // 2. Query Supabase using vector similarity
        const { data, error } = await supabaseAdmin.rpc('match_products', {
            query_embedding: embedding,
            match_threshold: 0.5,
            match_count: 5
        });

        if (error) throw error;
        return data;
    },

    // Collections
    async getCollections() {
        const { data, error } = await supabaseAdmin
            .from('collections')
            .select('*')
            .eq('is_active', true)
            .order('created_at', { ascending: false });

        if (error) throw error;
        return data;
    },

    async getCollectionDetail(slug: string) {
        const { data, error } = await supabaseAdmin
            .from('collections')
            .select(`
                *,
                products:collection_products(
                    product:products(
                        *,
                        brand:brands(*),
                        category:categories(*),
                        variants:product_variants(*),
                        images:product_images(*)
                    )
                )
            `)
            .eq('slug', slug)
            .single();

        if (error) throw error;
        return data;
    }
};
