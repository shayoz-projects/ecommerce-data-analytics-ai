## Prompt Evaluation 

This document describes how the AI insight layer changed across three prompt versions.

The goal was not only to generate a readable report, but also to check whether the output was accurate, traceable to the data and careful about unsupported conclusions.

## Prompt Evaluation Method

All three versions received the same aggregated metrics package. Raw customer and order-level data were not sent to the model. (raw revenue)

The outputs were checked against the SQL results and the analytical database, including:

- numerical values
- currency labels
- explanations presented as facts
- recommendations not supported by the data
- missing limitations

For the public repository, all three prompt versions were rerun using the same privacy-safe metrics package. 

## Version 1- Naive Prompt

The first version used one broad instruction:

*Analyse this data and provide business insights and recommendations.

There were no requirements for a fixed structure, evidence references, limitations or validation.

The result looked convincing and was easy to read, but manual verification found several problems:

- one total revenue value was copied incorrectly
- the report used a dollar symbol ($) even though the business operates in ILS
- some headings and explanations sounded more like marketing language than data analysis
- recommendations included targets and assumptions that were not supplied in the data
- there was no validation step to catch these issues

The main lesson from V1 was that a polished response is not necessarily an accurate one.

## Version 2- Structured Prompt

The second prompt required every insight to include:

1. Finding
2. Evidence
3. Interpretation
4. Recommended action
5. Data limitation

The evidence section also had to refer to the relevant fields from the supplied data.

This made the output easier to review. The findings were more cautious, each recommendation included a limitation.

For example, the model stated that frequent co-purchases did not prove that a cross-sell action would create additional sales.

However, V2 still relied on the model to copy the supplied numbers correctly. There was no automated check between the final response and the approved analytical source.

It also did not provide a clear confidence level for each insight.

## Version 3- Guarded Pipeline

V3 kept the structured format from V2 and added:

- a confidence level for each insight
- recommendations framed as proposed experiments
- an automated validation step

Instead of allowing the model to freely insert numerical values, the final workflow uses an approved fact catalogue.

The model selects the relevant fact IDs and writes the interpretation. Python then:

- checks that the selected fact IDs exist
- looks for predefined unsupported claims or risky wording
- checks for duplicate fact use
- inserts the approved numerical evidence
- creates the final report only after validation passes

This provided better control over numerical accuracy and made it easier to trace each finding back to its source.

Human review was still required because automated checks cannot evaluate every possible business interpretation.


## Final Decision

V2 was the main improvement because it changed the output from general, plausible-sounding text into a structured report that could be checked against the data.

V3 added another layer of control through fact IDs, confidence levels and Python validation. For that reason, V3 was selected as the final approach for the project.

The fact catalogue must be regenerated whenever:

- the source data changes
- cleaning logic changes
- product-classification rules change
- a KPI definition changes
