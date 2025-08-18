-- PostgreSQL initialization script for Vietnamese collation support
-- This script sets up Vietnamese text search and collation for SmartRestaurant

-- Create Vietnamese text search configuration
CREATE TEXT SEARCH CONFIGURATION vietnamese (COPY = simple);

-- Set Vietnamese locale and collation
ALTER DATABASE "SmartRestaurant" SET default_text_search_config = 'vietnamese';

-- Create indexes for Vietnamese text search on commonly searched fields
-- These will be applied when the actual tables are created by ABP migrations

-- Extension for unaccented text search (helpful for Vietnamese)
CREATE EXTENSION IF NOT EXISTS unaccent;

-- Create a function to remove Vietnamese diacritics for search
CREATE OR REPLACE FUNCTION remove_vietnamese_accents(text)
RETURNS text AS $$
BEGIN
    RETURN unaccent($1);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Create a custom Vietnamese text search function
CREATE OR REPLACE FUNCTION vietnamese_search(search_text text, target_text text)
RETURNS boolean AS $$
BEGIN
    RETURN remove_vietnamese_accents(upper(target_text)) LIKE '%' || remove_vietnamese_accents(upper(search_text)) || '%';
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Log the completion
DO $$
BEGIN
    RAISE NOTICE 'Vietnamese collation and text search setup completed for SmartRestaurant database';
END $$;