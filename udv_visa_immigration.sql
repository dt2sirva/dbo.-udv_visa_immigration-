USE [SEReports];
GO

WITH fp AS
(
	SELECT	[form_uid],
			ISNULL(dialing_prefix, '') + ISNULL(phone_country, '') + ' ' + ISNULL(phone_area_code, '') + ' ' + ISNULL(assignee_phone, '') AS [Assignee_Phone_Number]
	FROM	dbo.[form_0000_customer_05_phone] WITH (nolock)
	WHERE	cust_pref_nbr_ind = 'Y'

),
org AS
(
	SELECT	[org_uid],
			[org_name] AS [Client_Name]
	FROM	dbo.organization WITH (nolock)
),
fc AS
(
	SELECT	[form_uid],
			[citizenship_country],
			[dual_citizenship_country],
			[dt_new_assignment_begin] AS [Assignment_Est_Begin_Date],
			[new_assignment_job_title],
			[new_assignment_cost_center],
			[new_assignment_supervisor],
			[dt_birth_date],
			[TYCO_Actual_Start_Date],
			[birth_country]
	FROM	dbo.[form_0000_customer_05] WITH (nolock)
),
fcc AS
(
	SELECT	[form_uid],
			[ddlb_Employee_Hold_Dual_Citizenship],
			[cust_family_size_assig] AS [Family_Size_on_Assignment],
			[cust_Requisition_Number],
			[cust_New_Manager_Email],
			[c500_Immigration_Notes],
			[cust_curr_worksite_location],
			[cust_new_worksite_location],
			[business_unit_p],
			[misc3]
	FROM	dbo.[form_0000_customer_05_custom] WITH (nolock)
),
code1 AS
(
	SELECT	[code_value],
			[code_type],
			[code_desc]
	FROM	dbo.code WITH (nolock)
	WHERE	[code_type] = 'MARITA'
),
code2 AS
(
	SELECT	[code_value],
			[code_type],
			[code_desc]
	FROM	dbo.code WITH (nolock)
	WHERE	[code_type] = 'Countr'
),
code3 AS
(
	SELECT	[code_value],
			[code_desc]
	FROM dbo.[code] WITH (nolock)
	WHERE [code_type] = 'WORLOC'
),
code4 AS
(
	SELECT	[code_value],
			[code_desc]
	FROM	dbo.[code] WITH (nolock)
	WHERE	[code_type] = 'BUCode'
),
f7141A AS
(
	SELECT
			[form_uid],
			[cust_uid],
			[seq],
			UPPER(LTRIM(RTRIM([c100_document_type]))) AS [c100_document_type],
			LEN(LTRIM(RTRIM([c100_document_type]))) AS [CharLength],
			[dt_effective_date],
			[dt_expiration_date],
			UPPER(LTRIM(RTRIM([c500_document_comments]))) AS [c500_document_comments]
	FROM
			[dbo].[form_7141_Visa_Immigration_Permit_Confirmation_Document_Details] WITH (nolock)
),
f7141B AS
(
	SELECT
			f7141A.[form_uid],
			MAX(f7141A.[CharLength]) AS [MaxCharLength]
	FROM	f7141A
	GROUP BY f7141A.[form_uid]
),
f7141C AS
(
	SELECT
			f7141A.[form_uid],
			MAX(f7141A.[seq]) AS [seq]
	FROM f7141B INNER JOIN f7141A ON (f7141B.[form_uid] = f7141A.[form_uid]) AND (f7141B.[MaxCharLength] = f7141A.[CharLength])
	GROUP BY f7141A.[form_uid]
),
f7141D AS
(
	SELECT	f7141A.*
	FROM f7141C INNER JOIN f7141A ON (f7141C.[form_uid] = f7141A.[form_uid]) AND (f7141C.[seq] = f7141A.[seq])
),
dep1 AS
(
	SELECT	[form_uid],
			[ddlb_RELATE_cust_oth_relationship],
			[cust_oth_fname],
			[cust_oth_minitial],
			[cust_oth_lname],
			[dt_cust_oth_birth_date],
			[cust_oth_dual_citizenship_country]

	FROM	[dbo].[form_0000_customer_05_dependents] WITH (nolock)
	WHERE	[seq] = 1
)
SELECT
		c.[cust_uid] AS [Assignee_ID],
		c.[cust_fname] AS [Assignee_First_Name],
		c.[cust_lname] AS [Assignee_Last_Name],
		c.[cust_email] AS [Assignee_Preferred_Email],
		fp.[Assignee_Phone_Number],
		org.[Client_Name],
		p.[program_name] AS [Program],
		fc.[Assignment_Est_Begin_Date],
		fcc.[Family_Size_on_Assignment],
		ISNULL(code1.[code_desc], '') AS [Marital_Status],
		ISNULL(code2.[code_desc], '') AS [Citizenship],
		CASE fcc.[ddlb_Employee_Hold_Dual_Citizenship] WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END AS [Does_Employee_Hold_Dual_Citizenship],
		ISNULL(c2.code_desc, '') AS [Dual_Citizenship],
		CASE f7140.[chk_appvdForVisa_Assignee] WHEN 'Y' THEN 'Yes' WHEN 'N' THEN 'No' ELSE '' END AS [Approved_for_Visa_Immigration_Assistance],
		c.[cust_title] AS [CA-Position_Job_Title],
		fc.[new_assignment_job_title] AS [NA-Position_Job_Title],
		f7140.[dt_assigneeFirstContacted] AS [Date_Assignee_Contacted],
		f7140.[dt_Mgr_Recruiter_Contacted] AS [Date_Manager_Recruiter_Contacted],
		f7140.c500_specialInstructions AS [Addl_Comments-Concern-Potential_Issues-Specl_Instructions],
		CASE f7140.chk_PermResidencyOthCtry_Assignee WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Employee_hold_Permanent_Residency_in_any_other_country],
		CASE f7140.chk_PermResidencyOthCtry_Spouse WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Spouse_Hold_Permanent_Residency_in_any_Other_country],
		CASE f7140.chk_PermResidencyOthCtry_Child1 WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Child1_Hold_Permanent_Residency_in_any_Other_country],
		CASE f7140.chk_PermResidencyOthCtry_Child2 WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Child2_Hold_Permanent_Residency_in_any_Other_country],
		CASE f7140.chk_PermResidencyOthCtry_Child3 WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Child3_Hold_Permanent_Residency_in_any_Other_country],
		CASE f7140.chk_PermResidencyOthCtry_Child4 WHEN 'Y' THEN 'Yes' ELSE '' END AS [Does_Child4_Hold_Permanent_Residency_in_any_Other_country],
		f7140.travel_document_type AS [Type_of_Travel_Document],
		f7140.permit_type AS [Permit_Type],
		f7140.existing_permit_number AS [Existing_Permit_Number],
		f7140.name_on_passport AS [Name_on_Passport],
		f7140.c100_Father_Legal_Name AS [Fathers_Name],
		ISNULL((SELECT code_desc FROM code2 WHERE code_value = f7140.ddlb_COUNTR_Father_Citizenship), '') AS [Fathers_Nationality],
		f7140.c100_Mother_Legal_Name AS [Mothers_Name],
		f7147.mny_EstTotalCost AS [Estimated_Total_Cost],
		f7147.visaEstTimeToObtain AS [Estimated_Time_to_Obtain_Visa],
		f7147.visaEstTimeForExtension AS [Estimated_Processing_Times_for_Extension],
		f7141.dt_entry_visa_recvd_by_employee AS [Date_Entry_Visa_Received_by_Employee],
		f7141.dt_residencePermitApplied_Assignee AS [Residence_Permit_Applied_Date],
		f7141.dt_workPermitExpire_Assignee AS [Work_Permit_Expiration_Date],
		f7141.dt_residencePermitExpire_Assignee AS [Residence_Permit_Expiration_Date],
		f7141.dt_visaExpiration_Assignee AS [Visa_Expiration_Date],
		f7141.dt_residencePermitExpire_Spouse AS [Spouse_Residence_Permit_Expiration_date],
		f7141.dt_residencePermitExpire_Child1 AS [Child1_Residence_Permit_Expiration_date],
		f7141.dt_residencePermitExpire_Child2 AS [Child2_Residence_Permit_Expiration_date],
		f7141.dt_residencePermitExpire_Child3 AS [Child3_Residence_Permit_Expiration_date],
		f7141.dt_residencePermitExpire_Child4 AS [Child4_Residence_Permit_Expiration_date],
		f7141.dt_visaExpiration_Spouse AS [Spouse_Visa_Expiration_Date],
		f7141.dt_visaExpiration_Child1 AS [Child1_Visa_Expiration_Date],
		f7141.dt_visaExpiration_Child2 AS [Child2_Visa_Expiration_Date],
		f7141.dt_visaExpiration_Child3 AS [Child3_Visa_Expiration_Date],
		f7141.dt_visaExpiration_Child4 AS [Child4_Visa_Expiration_Date],
		f7141.dt_employee_entered_host_country AS [Date_Employee_Entered_Host_Country],
		f7141.dt_residence_permit_completed AS [Date_Residence_Permit_Completed],
		f7141.dt_workPermitEffective_Assignee AS [EE_Work_Permit_Effective_Dt],
		c.[cust_ref_nbr] AS [Client_Employee_ID],
		c.[cust_cost_center] AS [CA-Client_Cost_Center_ID],
		fc.[new_assignment_cost_center] AS [NA-Client_Cost_Center_ID],
		fc.[new_assignment_supervisor] AS [New-Manager_Name],
		fc.[dt_birth_date] AS [Birth_Date],
		fc.[TYCO_Actual_Start_Date] AS [Actual_Start_Date],
		c.[cust_org_uid] AS [udv_org_uid],
		f7141D.[c100_document_type] AS [Document_Type],
		f7141D.[dt_effective_date] AS [Effective_Date],
		f7141D.[dt_expiration_date] AS [Expiration_Date],
		f7141D.[c500_document_comments] AS [Document_Comments],
		fcc.[cust_Requisition_Number] AS [Requisition_Number],
		fcc.[cust_New_Manager_Email] AS [New_Manager_Email_address],
		fcc.[c500_immigration_notes] AS [Any_Additional_Immigraton_Notes],
		f7144.[date_docs_recvd_from_employee] AS [Date_Documents_Received_from_Employee],
		f7144.[date_forms_sent_to_employee_for_sig] AS [Date_Forms_Sent_to_Employee_for_Signature],
		f7144.[date_forms_sent_to_manager_for_sig] AS [Date_Forms_Sent_to_Manager_for_Signature],
		f7144.[dt_visaDocumentationReceived] AS [Documents_Received],
		f7144.[dt_entry_visa_info_pack_sent] AS [Date_Entry_Visa_Info_Pack_Sent],
		f7145.[dt_visaGovtApprovalReceived] AS [Government_Approval_Received],
		f7145.[dt_client_informed_of_decision] AS [Date_Client_Informed_of_Decision],
		f7145.[dt_employee_informed_of_decision] AS [Date_Employee_Informed_of_Decision],
		f7142.[dt_visaApplicationFiled] AS [VI_Application_Filed_Date],
		f7148.[dt_visaSignedDocumentsReceived] AS [Date_Signed_Documents_Received_from_Client_by_Vendor],
		ISNULL(code3.[code_desc], '') AS [Apple Home Entity],
		ISNULL(code3_1.[code_desc], '') AS [Apple Host Entity],
		ISNULL(code2_1.[code_desc], '') AS [Birth_Country],
		ISNULL(code4_1.[code_desc], '') AS [CA-Business_Unit],
		ISNULL(code4_2.[code_desc], '') AS [NA-Business_Unit],
		dep1.[ddlb_RELATE_cust_oth_relationship] AS [Accompanying_Family_Details-Relationship_Dependent1],
		(dep1.cust_oth_fname + ' ' + dep1.cust_oth_minitial + ' ' + dep1.cust_oth_lname) AS [Accompanying_Family_Details-Full_Name_Dependent1],
		dep1.[dt_cust_oth_birth_date] AS [Accompanying_Family_Details-Date_of_Birth_Dependent1],
		ISNULL(code2_2.[code_desc], '') AS [Dual_Nationality_if_Applicable_Dependent1]

FROM	dbo.[customer] AS c WITH (nolock)
INNER JOIN dbo.[program] AS p WITH (nolock) ON c.[program_uid] = p.[program_uid]
LEFT OUTER JOIN fp ON p.[form_uid] = fp.[form_uid]
LEFT OUTER JOIN org ON c.[cust_org_uid] = org.[org_uid]
LEFT OUTER JOIN fc ON p.[form_uid] = fc.[form_uid]
LEFT OUTER JOIN fcc ON p.[form_uid] = fcc.[form_uid]
LEFT OUTER JOIN code1 ON (c.[cust_marital_status] = code1.[code_value])
LEFT OUTER JOIN	code2 ON fc.[citizenship_country] = code2.[code_value]
LEFT OUTER JOIN code2 AS c2 ON fc.[dual_citizenship_country] = c2.[code_value]
LEFT OUTER JOIN dbo.[form_7140_visa_immigration_initiation] AS f7140 WITH (nolock) ON (p.[form_uid] = f7140.[form_uid])
LEFT OUTER JOIN dbo.[form_7147_visa_immigration_details] AS f7147 WITH (nolock) ON (p.[form_uid] = f7147.[form_uid])
LEFT OUTER JOIN dbo.[form_7141_visa_immigration_permit_confirmation] AS f7141 WITH (nolock) ON (p.[form_uid] = f7141.[form_uid])
LEFT OUTER JOIN f7141D ON (p.[form_uid] = f7141D.[form_uid])
LEFT OUTER JOIN dbo.[form_7144_visa_immigration_documentation_received] AS f7144 WITH (nolock) ON (p.[form_uid] = f7144.[form_uid])
LEFT OUTER JOIN dbo.[form_7145_visa_immigration_govtapprovalreceived] AS f7145 WITH (nolock) ON (p.[form_uid] = f7145.[form_uid])
LEFT OUTER JOIN dbo.[form_7142_visa_immigration_application_filed] AS f7142 WITH (nolock) ON (p.[form_uid] = f7142.[form_uid])
LEFT OUTER JOIN dbo.[form_7148_visa_immigration_signed_documents_rcvd] AS f7148 WITH (nolock) ON (p.[form_uid] = f7148.[form_uid])
LEFT OUTER JOIN code3 ON (code3.[code_value] = fcc.[cust_curr_worksite_location])
LEFT OUTER JOIN code3 AS code3_1 ON (code3_1.[code_value] = fcc.[cust_new_worksite_location])
LEFT OUTER JOIN code2 AS code2_1 ON (code2_1.[code_value] = fc.[birth_country])
LEFT OUTER JOIN code4 AS code4_1 ON (code4_1.[code_value] = fcc.[business_unit_p])
LEFT OUTER JOIN code4 AS code4_2 ON (code4_2.[code_value] = fcc.[misc3])
LEFT OUTER JOIN dep1 ON (p.[form_uid] = dep1.[form_uid])
LEFT OUTER JOIN code2 AS code2_2 ON (code2_2.[code_value] = dep1.[cust_oth_dual_citizenship_country])
;
