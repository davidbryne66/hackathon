// Source table declarations
const sourceConfig = {
  schema: dataform.projectConfig.vars.source_dataset,
  database: dataform.projectConfig.vars.source_project
};

// Only declare tables we need for fct_product_reviews
declare({
  ...sourceConfig,
  name: "Production_ProductReview"
});

declare({
  ...sourceConfig,
  name: "Production_Product"
});

declare({
  ...sourceConfig,
  name: "Production_ProductSubcategory"
});

declare({
  ...sourceConfig,
  name: "Production_ProductCategory"
});
