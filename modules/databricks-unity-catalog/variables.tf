variable "catalog_name" {
  description = "Name of the catalog to create (e.g. mdp_dev)."
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket backing this catalog's external location."
  type        = string
}

variable "iam_role_arn" {
  description = "ARN of the IAM role Unity Catalog assumes to access this catalog's S3 bucket."
  type        = string
}

variable "schemas" {
  description = "Schemas to create in the catalog, as name => comment. The default is the single_workspace list; free_workspace passes its own."
  type        = map(string)
  default = {
    bronze_neon                = "Raw Neon Postgres ingestion landing zone"
    bronze_neon_publish        = "Publish-ready view of Neon bronze data (incl. SCD1/SCD2 tables)"
    bronze_atlas               = "Raw MongoDB Atlas ingestion landing zone"
    bronze_atlas_publish       = "Publish-ready view of Atlas bronze data"
    bronze_clickstream         = "Raw clickstream file-drop ingestion landing zone"
    bronze_clickstream_publish = "Publish-ready view of clickstream bronze data (incl. SCD1 table)"
    bronze_ungm                = "Raw UNGM API ingestion landing zone"
    bronze_ungm_publish        = "Publish-ready view of UNGM bronze data (incl. SCD1/SCD2 tables)"
    bronze_acnc                = "Raw ACNC Charity Register ingestion landing zone"
    bronze_acnc_publish        = "Publish-ready view of ACNC bronze data (incl. SCD1/SCD2 tables)"
    bronze_nsw_spatial         = "Raw NSW Spatial Services ingestion landing zone"
    bronze_nsw_spatial_publish = "Publish-ready view of NSW Spatial Services bronze data (incl. SCD1/SCD2 tables)"
    bronze_airroi              = "Raw AirROI market intelligence ingestion landing zone"
    bronze_airroi_publish      = "Publish-ready view of AirROI bronze data (incl. SCD2 table)"
    bronze_iso                 = "Raw ISO 3166 country/subdivision reference ingestion landing zone"
    bronze_iso_publish         = "Publish-ready view of ISO 3166 bronze data (incl. SCD1/SCD2 tables)"
    bronze_geonames            = "Raw GeoNames gazetteer reference ingestion landing zone"
    bronze_geonames_publish    = "Publish-ready view of GeoNames bronze data (incl. SCD2 tables)"
    silver_landing_neon        = "Source-aligned Silver Landing for Neon (customers, products, orders, order_items)"
    silver_landing_clickstream = "Source-aligned Silver Landing for clickstream (web_events)"
    silver_landing_ungm        = "Source-aligned Silver Landing for UNGM (unspsc_public)"
    silver_landing_acnc        = "Source-aligned Silver Landing for ACNC (charity_register)"
    silver_landing_nsw_spatial = "Source-aligned Silver Landing for NSW Spatial Services (property)"
    silver_landing_airroi      = "Source-aligned Silver Landing for AirROI (market_metrics_all, market_summary)"
    silver_landing_iso         = "Source-aligned Silver Landing for ISO 3166 (country_codes, subdivision_codes)"
    silver_landing_geonames    = "Source-aligned Silver Landing for GeoNames (country_info, admin1_codes, admin2_codes, cities)"
    silver_normalised_airroi   = "Source-aligned Silver Normalised for AirROI (3NF + extracted entities)"
    silver_normalised_acnc     = "Source-aligned Silver Normalised for ACNC (3NF + extracted entities, bridges)"
    bronze_wikipedia           = "Raw Wikipedia S&P 500 list (CIK, date added) ingestion landing zone"
    bronze_wikipedia_publish   = "Publish-ready view of wikipedia bronze data (incl. SCD tables)"
    silver_landing_wikipedia   = "Source-aligned Silver Landing for wikipedia"
    bronze_sec                 = "Raw SEC EDGAR (ticker to CIK, company facts) ingestion landing zone"
    bronze_sec_publish         = "Publish-ready view of sec bronze data (incl. SCD tables)"
    silver_landing_sec         = "Source-aligned Silver Landing for sec"
    bronze_yahoo               = "Raw Yahoo Finance (prices, dividends, options activity) ingestion landing zone"
    bronze_yahoo_publish       = "Publish-ready view of yahoo bronze data (incl. SCD tables)"
    silver_landing_yahoo       = "Source-aligned Silver Landing for yahoo"
    bronze_rba                 = "Raw RBA (AUD exchange rates, cash rate) ingestion landing zone"
    bronze_rba_publish         = "Publish-ready view of rba bronze data (incl. SCD tables)"
    silver_landing_rba         = "Source-aligned Silver Landing for rba"
    bronze_fred                = "Raw FRED (US 10-year Treasury yield) ingestion landing zone"
    bronze_fred_publish        = "Publish-ready view of fred bronze data (incl. SCD tables)"
    silver_landing_fred        = "Source-aligned Silver Landing for fred"
    bronze_portfolio           = "Raw purchases file landing zone (the user's CSV)"
    bronze_portfolio_publish   = "Publish-ready view of portfolio bronze data (incl. SCD tables)"
    silver_landing_portfolio   = "Source-aligned Silver Landing for portfolio"
    silver_domain_investments  = "Silver Domain: conformed companies, dividends, prices, fundamentals and rates for the dividend portfolio story"
    gold_analytics_gateway     = "Analytics-facing gold layer"
    gold_integration_gateway   = "Integration-facing gold layer"
    gold_ai_gateway            = "AI/ML-facing gold layer"
  }
}
