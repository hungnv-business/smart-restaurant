  -- Function để populate data
  CREATE OR REPLACE FUNCTION populate_dim_date(start_year
  INTEGER, end_year INTEGER)
  RETURNS VOID AS $$
  DECLARE
      iter_date DATE;
      end_date DATE;
      week_num INTEGER;
      quarter_start_date DATE;
      date_id INTEGER;
  BEGIN
      -- Xóa dữ liệu cũ nếu có
      DELETE FROM "AppDimDates" WHERE num_year BETWEEN start_year
  AND end_year;

      iter_date := DATE(start_year || '-01-01');
      end_date := DATE(end_year || '-12-31');

      WHILE iter_date <= end_date LOOP
          quarter_start_date := DATE_TRUNC('quarter',
  iter_date);
          week_num := EXTRACT(WEEK FROM iter_date);

          -- Tạo ID theo format yyyyMMdd
          date_id := TO_CHAR(iter_date, 'YYYYMMDD')::INTEGER;

          INSERT INTO "AppDimDates" (
              "Id",
              date,
              date_vn_format,
              date_vn_short_format,
              date_uk_format,
              date_uk_short_format,
              date_us_format,
              date_us_short_format,
              date_iso_format,
              num_year,
              num_quarter_in_year,
              num_month_in_year,
              num_month_in_quarter,
              num_week_in_year,
              num_week_in_quarter,
              num_week_in_month,
              num_day_in_year,
              num_day_in_quarter,
              num_day_in_month,
              num_day_in_week,
              is_holiday_us,
              name_month_en,
              name_month_abbreviated_en,
              name_day_en,
              name_day_abbreviated_en
          ) VALUES (
              date_id,
              iter_date,
              TO_CHAR(iter_date, 'DD/MM/YYYY'),
              TO_CHAR(iter_date, 'DD/MM/YY'),
              TO_CHAR(iter_date, 'DD/MM/YYYY'),
              TO_CHAR(iter_date, 'DD/MM/YY'),
              TO_CHAR(iter_date, 'MM/DD/YYYY'),
              TO_CHAR(iter_date, 'MM/DD/YY'),
              TO_CHAR(iter_date, 'YYYY-MM-DD'),
              EXTRACT(YEAR FROM iter_date)::INTEGER,
              EXTRACT(QUARTER FROM iter_date)::INTEGER,
              EXTRACT(MONTH FROM iter_date)::INTEGER,
              (EXTRACT(MONTH FROM iter_date) - EXTRACT(MONTH
  FROM quarter_start_date) + 1)::INTEGER,
              week_num,
              (week_num - EXTRACT(WEEK FROM
  quarter_start_date) + 1)::INTEGER,
              CEILING(EXTRACT(DAY FROM iter_date) /
  7.0)::INTEGER,
              EXTRACT(DOY FROM iter_date)::INTEGER,
              (iter_date - quarter_start_date + 1)::INTEGER,
              EXTRACT(DAY FROM iter_date)::INTEGER,
              EXTRACT(DOW FROM iter_date)::INTEGER,
              FALSE,
              TRIM(TO_CHAR(iter_date, 'Month')),
              TO_CHAR(iter_date, 'Mon'),
              TRIM(TO_CHAR(iter_date, 'Day')),
              TO_CHAR(iter_date, 'Dy')
          );

          iter_date := iter_date + INTERVAL '1 day';
      END LOOP;
  END;
  $$ LANGUAGE plpgsql;

  SELECT populate_dim_date(2000, 2100);

  -- Verify data
  SELECT COUNT(*) as total_records FROM "AppDimDates";
  SELECT "Id", date, date_vn_format FROM "AppDimDates" ORDER BY date
   LIMIT 10;