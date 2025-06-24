use chrono::{DateTime, Utc};
use serde::{Deserialize, Deserializer, Serialize, Serializer};

/// ISO 8601 date string wrapper for consistent date handling across plugins
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct IsoDate(pub DateTime<Utc>);

impl IsoDate {
    pub fn now() -> Self {
        Self(Utc::now())
    }
    
    pub fn from_timestamp(secs: i64) -> Self {
        Self(DateTime::from_timestamp(secs, 0).unwrap_or_else(|| Utc::now()))
    }
}

impl Serialize for IsoDate {
    fn serialize<S>(&self, serializer: S) -> Result<S::Ok, S::Error>
    where
        S: Serializer,
    {
        serializer.serialize_str(&self.0.to_rfc3339())
    }
}

impl<'de> Deserialize<'de> for IsoDate {
    fn deserialize<D>(deserializer: D) -> Result<Self, D::Error>
    where
        D: Deserializer<'de>,
    {
        let s = String::deserialize(deserializer)?;
        DateTime::parse_from_rfc3339(&s)
            .map(|dt| IsoDate(dt.with_timezone(&Utc)))
            .map_err(serde::de::Error::custom)
    }
}

/// Date range for querying data
#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct DateRange {
    pub start_date: IsoDate,
    pub end_date: IsoDate,
}

impl DateRange {
    pub fn new(start: DateTime<Utc>, end: DateTime<Utc>) -> Self {
        Self {
            start_date: IsoDate(start),
            end_date: IsoDate(end),
        }
    }
    
    pub fn today() -> Self {
        let now = Utc::now();
        let start = now.date_naive().and_hms_opt(0, 0, 0).unwrap().and_utc();
        let end = now.date_naive().and_hms_opt(23, 59, 59).unwrap().and_utc();
        Self::new(start, end)
    }
    
    pub fn is_valid(&self) -> bool {
        self.start_date.0 <= self.end_date.0
    }
}