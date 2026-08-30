# CERN Industrial Return & Procurement Threshold Compliance Engine

This project analyzes two real CERN procurement concepts: industrial return (how much a member state gets back in contracts relative to what it contributes) and threshold-based tendering rules (which approval process a purchase needs, based on its size).

## Overview

The project analyses 2,000 contract awards across 20 countries and 4 procurement categories, together with 1,500 purchase requisitions.

The goal is to turn procurement transactions into useful reporting around award distribution, procurement return and threshold-related patterns.

## What I worked on

- A schema tracking member state contributions, contract awards, and purchase requisitions
- PL/SQL logic calculating each country's industrial return gap against its contribution share
- PL/SQL logic classifying purchase requisitions into CERN's real threshold bands
- A split-purchase detection query to flag suspicious patterns of many small purchases to the same supplier in one month
- Created interactive procurement reporting visualisations

## Procurement return analysis and findings

Country-level award share was compared with contribution share to identify differences between participation and awarded business.

This provides a simple way to identify areas that may require further procurement analysis.

Switzerland and India were the most over-returned countries, with return gaps of +8.71 and +8.5 respectively. Germany was the most under-returned, at -15.7, followed by the United Kingdom and France.

## Threshold analysis and findings

Purchase requisitions were classified into procedure bands based on their value.

The analysis was used to understand how requisitions were distributed across the different threshold levels.

Out of 1,500 purchase requisitions: 1,200 were routine purchases, 150 required a mid-tier approval process, and 150 required competitive tendering.

## Split-purchase risk flags
Several suppliers were flagged for having many small purchases bunched into a single month that together exceeded CHF 15,000. The highest-risk cases involved over CHF 150,000 in fragmented purchases to a single supplier in one month.

The analysis does not treat these patterns as proof of non-compliance.

## Reporting

The final reporting layer visualises:

- Country-level award distribution
- Procurement category patterns
- Contribution versus award share
- Threshold classifications
- Requisition patterns

## Tools

- Oracle SQL
- PL/SQL
- Tableau

## Files in this repo
- industrial_return_script.sql — the complete script, from table creation through the compliance and split-purchase queries

## Note
Member state contribution percentages used here are approximate, for illustration, not CERN's official figures.
