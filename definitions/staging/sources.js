// Source table declarations for Adventure Works OLTP
// This makes source tables available via ${ref('table_name')} syntax

const sourceConfig = {
  schema: dataform.projectConfig.vars.source_dataset,
  database: dataform.projectConfig.vars.source_project
};

// Sales tables
declare({
  ...sourceConfig,
  name: "Sales_SalesOrderHeader"
});

declare({
  ...sourceConfig,
  name: "Sales_SalesOrderDetail"
});

declare({
  ...sourceConfig,
  name: "Sales_Customer"
});

declare({
  ...sourceConfig,
  name: "Sales_CurrencyRate"
});

declare({
  ...sourceConfig,
  name: "Sales_SalesTerritory"
});

declare({
  ...sourceConfig,
  name: "Sales_SalesPerson"
});

declare({
  ...sourceConfig,
  name: "Sales_SpecialOffer"
});

declare({
  ...sourceConfig,
  name: "Sales_CreditCard"
});

declare({
  ...sourceConfig,
  name: "Sales_Currency"
});

declare({
  ...sourceConfig,
  name: "Sales_Store"
});

// Production tables
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

declare({
  ...sourceConfig,
  name: "Production_ProductInventory"
});

declare({
  ...sourceConfig,
  name: "Production_ProductReview"
});

declare({
  ...sourceConfig,
  name: "Production_WorkOrder"
});

declare({
  ...sourceConfig,
  name: "Production_Location"
});

declare({
  ...sourceConfig,
  name: "Production_ScrapReason"
});

// Purchasing tables
declare({
  ...sourceConfig,
  name: "Purchasing_PurchaseOrderHeader"
});

declare({
  ...sourceConfig,
  name: "Purchasing_PurchaseOrderDetail"
});

declare({
  ...sourceConfig,
  name: "Purchasing_Vendor"
});

declare({
  ...sourceConfig,
  name: "Purchasing_ShipMethod"
});

// Person tables
declare({
  ...sourceConfig,
  name: "Person_Person"
});

declare({
  ...sourceConfig,
  name: "Person_Address"
});

declare({
  ...sourceConfig,
  name: "Person_StateProvince"
});

declare({
  ...sourceConfig,
  name: "Person_CountryRegion"
});

// HumanResources tables
declare({
  ...sourceConfig,
  name: "HumanResources_Employee"
});
