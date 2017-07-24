USE [SEReports]
GO

/****** Object:  View [dbo].[udv_Visa_Immigration]    Script Date: 7/17/2017 10:31:46 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*************************************************************************
*  Object Name: udv_Visa_Immigration 
*  Object Type: View
*  Programmer : Buzz Marchese
*  Create Date: 03/29/13
*  Description: Adhoc report view for All Visa Immigration report
************************************************************************** 
*  Revision History:
*  
*  TFS 19719, 03/29/2013, Buzz Marchese: Original 
*  TFS 20012, 04/04/2013, Buzz Marchese: Changed CA_Worksite_Location and 
*             Apple Host Entity names cnd changed to use code table.
*             Also added 3 addtnl fields
*  TFS 25246, 09/18/2013, Buzz Marchese: Added 9 additional fields
*  TFS 32069, 01/28/2014, Buzz Marchese: Original from udv_Visa_Immigration_Apple (removed Apple restriction only)
*  VSTS	11329, 06/07/2016, Basav Bettaygowda: Fix SubQuery Error for Billing Location
*  VSTS 13980 10/4/2016 - Joe Wortman
**************************************************************************/
CREATE VIEW [dbo].[udv_Visa_Immigration]
AS

select 	distinct a.cust_uid as 'Assignee_ID',
		a.cust_fname as 'Assignee_First_Name',
		a.cust_lname as 'Assignee_Last_Name',
		a.cust_email as 'Assignee_Preferred_Email',
		rv_phone.Preferred_Phone_Number as 'Assignee_Phone_Number',
		a.org_name as 'Client_Name',
		a.[program_name] as 'Program',
		c.dt_new_assignment_begin as 'Assignment_Est_Begin_Date',
		cf.cust_family_size_assig as 'Family_Size_on_Assignment',
		ISNULL((SELECT code_desc FROM dbo.code AS code_26
			WHERE (code_value = a.cust_marital_status) AND (code_type = 'MARITA')), '') AS 'Marital_Status',
		ISNULL((SELECT code_desc FROM dbo.code AS code_23
			WHERE (code_value = c.citizenship_country) AND (code_type = 'Countr')), '') AS 'Citizenship',
		CASE WHEN cf.ddlb_Employee_Hold_Dual_Citizenship = 'Y' THEN 'Yes' WHEN cf.ddlb_Employee_Hold_Dual_Citizenship = 'N' THEN 'No' ELSE '' END AS 'Does_Employee_Hold_Dual_Citizenship',
		ISNULL((SELECT code_desc FROM dbo.code AS code_24
			WHERE (code_value = c.dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Citizenship',
		CASE WHEN f7140.chk_appvdForVisa_Assignee = 'Y' THEN 'Yes' WHEN f7140.chk_appvdForVisa_Assignee = 'N' THEN 'No' ELSE '' END AS 'Approved_for_Visa_Immigration_Assistance',
		a.job_title_home as 'CA-Position_Job_Title',
		a.new_assignment_job_title as 'NA-Position_Job_Title',
		f7140.dt_assigneeFirstContacted as 'Date_Assignee_Contacted',
		f7140.dt_Mgr_Recruiter_Contacted as 'Date_Manager_Recruiter_Contacted',
		f7140.c500_specialInstructions as 'Addl_Comments-Concern-Potential_Issues-Specl_Instructions',
		CASE WHEN f7140.chk_PermResidencyOthCtry_Assignee = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Employee_hold_Permanent_Residency_in_any_other_country',
		CASE WHEN f7140.chk_PermResidencyOthCtry_Spouse = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Spouse_Hold_Permanent_Residency_in_any_Other_country',	
		CASE WHEN f7140.chk_PermResidencyOthCtry_Child1 = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Child1_Hold_Permanent_Residency_in_any_Other_country',	
		CASE WHEN f7140.chk_PermResidencyOthCtry_Child2 = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Child2_Hold_Permanent_Residency_in_any_Other_country',	
		CASE WHEN f7140.chk_PermResidencyOthCtry_Child3 = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Child3_Hold_Permanent_Residency_in_any_Other_country',	
		CASE WHEN f7140.chk_PermResidencyOthCtry_Child4 = 'Y' THEN 'Yes' ELSE '' END AS 'Does_Child4_Hold_Permanent_Residency_in_any_Other_country',
		f7140.travel_document_type as 'Type_of_Travel_Document',
		f7140.permit_type as 'Permit_Type',
		f7140.existing_permit_number as 'Existing_Permit_Number',
		f7140.name_on_passport as 'Name_on_Passport',
		Fathers_Name = f7140.c100_Father_Legal_Name,
		Fathers_Nationality = ISNULL((SELECT code_desc FROM dbo.code WHERE code_value = f7140.ddlb_COUNTR_Father_Citizenship AND code_type = 'Countr'), ''),
		Mothers_Name = f7140.c100_Mother_Legal_Name,
		Mothers_Nationality = ISNULL((SELECT code_desc FROM dbo.code WHERE code_value = f7140.ddlb_COUNTR_Mother_Citizenship AND code_type = 'Countr'), ''),
		f7147.mny_EstTotalCost as 'Estimated_Total_Cost',
		f7147.visaEstTimeToObtain as 'Estimated_Time_to_Obtain_Visa',
		f7147.visaEstTimeForExtension as 'Estimated_Processing_Times_for_Extension',
		f7141.dt_entry_visa_recvd_by_employee as 'Date_Entry_Visa_Received_by_Employee',
		f7141.dt_residencePermitApplied_Assignee as 'Residence_Permit_Applied_Date',
		f7141.dt_workPermitExpire_Assignee as 'Work_Permit_Expiration_Date',
		f7141.dt_residencePermitExpire_Assignee as 'Residence_Permit_Expiration_Date',
		f7141.dt_visaExpiration_Assignee as 'Visa_Expiration_Date',
		f7141.dt_residencePermitExpire_Spouse as 'Spouse_Residence_Permit_Expiration_date',
		f7141.dt_residencePermitExpire_Child1 as 'Child1_Residence_Permit_Expiration_date',
		f7141.dt_residencePermitExpire_Child2 as 'Child2_Residence_Permit_Expiration_date',
		f7141.dt_residencePermitExpire_Child3 as 'Child3_Residence_Permit_Expiration_date',
		f7141.dt_residencePermitExpire_Child4 as 'Child4_Residence_Permit_Expiration_date',
		f7141.dt_visaExpiration_Spouse as 'Spouse_Visa_Expiration_Date',
		f7141.dt_visaExpiration_Child1 as 'Child1_Visa_Expiration_Date',
		f7141.dt_visaExpiration_Child2 as 'Child2_Visa_Expiration_Date',
		f7141.dt_visaExpiration_Child3 as 'Child3_Visa_Expiration_Date',
		f7141.dt_visaExpiration_Child4 as 'Child4_Visa_Expiration_Date',
		f7141.dt_employee_entered_host_country as 'Date_Employee_Entered_Host_Country',
		f7141.dt_residence_permit_completed as 'Date_Residence_Permit_Completed',
		f7141.dt_workPermitEffective_Assignee as 'EE_Work_Permit_Effective_Dt',
		cu.cust_ref_nbr as 'Client_Employee_ID',
		cu.cust_cost_center as 'CA-Client_Cost_Center_ID',
		c.new_assignment_cost_center as 'NA-Client_Cost_Center_ID',
		c.new_assignment_supervisor as 'New-Manager_Name',
		c.dt_birth_date as 'Birth_Date',
		c.TYCO_Actual_Start_Date as 'Actual_Start_Date', 
		a.org_uid as udv_org_uid,
		Document_Type = cdd.c100_document_type,
		Effective_Date = cdd.dt_effective_date,
		Expiration_Date = cdd.dt_expiration_date,
		Document_Comments = cdd.c500_document_comments,
		cf.cust_Requisition_Number as 'Requisition_Number',
		cf.cust_New_Manager_Email as 'New_Manager_Email_address',
		cf.c500_immigration_notes as 'Any_Additional_Immigraton_Notes',
		f7144.date_docs_recvd_from_employee as 'Date_Documents_Received_from_Employee',
		f7144.date_forms_sent_to_employee_for_sig as 'Date_Forms_Sent_to_Employee_for_Signature',
		f7144.date_forms_sent_to_manager_for_sig as 'Date_Forms_Sent_to_Manager_for_Signature',
		f7144.dt_visaDocumentationReceived as 'Documents_Received',
		f7144.dt_entry_visa_info_pack_sent as 'Date_Entry_Visa_Info_Pack_Sent',
		f7145.dt_visaGovtApprovalReceived as 'Government_Approval_Received',
		f7145.dt_client_informed_of_decision as 'Date_Client_Informed_of_Decision',
		f7145.dt_employee_informed_of_decision as 'Date_Employee_Informed_of_Decision',
		f7142.dt_visaApplicationFiled as 'VI_Application_Filed_Date',
		f7148.dt_visaSignedDocumentsReceived as 'Date_Signed_Documents_Received_from_Client_by_Vendor',
		ISNULL((SELECT code_desc FROM dbo.code AS code_31
			WHERE (code_value = cf.cust_Curr_Worksite_Location) AND (code_type = 'WORLOC')), '') AS 'Apple Home Entity',
		ISNULL((SELECT code_desc FROM dbo.code AS code_31
			WHERE (code_value = cf.cust_New_Worksite_Location) AND (code_type = 'WORLOC')), '') AS 'Apple Host Entity',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = c.birth_country) AND (code_type = 'COUNTR')), '') AS 'Birth_Country',
		ISNULL((SELECT code_desc FROM dbo.code AS code_31
			WHERE (code_value = cf.business_unit_p) AND (code_type = 'BUCode')), '') AS 'CA-Business_Unit',
		ISNULL((SELECT code_desc FROM dbo.code AS code_29
			where code_type = 'BUCode' and code_value = cf.misc3), '') as 'NA-Business_Unit',
		dep1.ddlb_RELATE_cust_oth_relationship as 'Accompanying_Family_Details-Relationship_Dependent1',
		(dep1.cust_oth_fname + ' ' + dep1.cust_oth_minitial + ' ' + dep1.cust_oth_lname) as 'Accompanying_Family_Details-Full_Name_Dependent1',	
		dep1.dt_cust_oth_birth_date as 'Accompanying_Family_Details-Date_of_Birth_Dependent1',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = dep1.cust_oth_dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Nationality_if_Applicable_Dependent1',		
			

		ISNULL ((SELECT cont_fname + ' ' + cont_lname AS 'Name'
			FROM dbo.contact AS contact_4
			WHERE (cont_uid = a.cust_referring_uid)), '') AS 'Client_Contact',
		ISNULL((SELECT code_desc FROM dbo.code_sirva AS code_32
			WHERE (code_value = cf.divisionlevel) AND (org_root_uid = a.org_root_uid) AND (code_type = 'DIVSON')), '') AS 'Division',
		dep2.ddlb_RELATE_cust_oth_relationship as 'Accompanying_Family_Details-Relationship_Dependent2',
		(dep2. cust_oth_fname + ' ' + dep2.cust_oth_minitial + ' ' + dep2.cust_oth_lname) as 'Accompanying_Family_Details-Full_Name_Dependent2',
		dep2.dt_cust_oth_birth_date as 'Accompanying_Family_Details-Date_of_Birth_Dependent2',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = dep2.cust_oth_dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Nationality_if_Applicable_Dependent2',
		dep3.ddlb_RELATE_cust_oth_relationship as 'Accompanying_Family_Details-Relationship_Dependent3',
		(dep3. cust_oth_fname + ' ' + dep3.cust_oth_minitial + ' ' + dep3.cust_oth_lname) as 'Accompanying_Family_Details-Full_Name_Dependent3',
		dep3.dt_cust_oth_birth_date as 'Accompanying_Family_Details-Date_of_Birth_Dependent3',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = dep3.cust_oth_dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Nationality_if_Applicable_Dependent3',
		dep4.ddlb_RELATE_cust_oth_relationship as 'Accompanying_Family_Details-Relationship_Dependent4',
		(dep4. cust_oth_fname + ' ' + dep4.cust_oth_minitial + ' ' + dep4.cust_oth_lname) as 'Accompanying_Family_Details-Full_Name_Dependent4',
		dep3.dt_cust_oth_birth_date as 'Accompanying_Family_Details-Date_of_Birth_Dependent4',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = dep4.cust_oth_dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Nationality_if_Applicable_Dependent4',
		dep5.ddlb_RELATE_cust_oth_relationship as 'Accompanying_Family_Details-Relationship_Dependent5',
		(dep5. cust_oth_fname + ' ' + dep5.cust_oth_minitial + ' ' + dep5.cust_oth_lname) as 'Accompanying_Family_Details-Full_Name_Dependent5',
		dep5.dt_cust_oth_birth_date as 'Accompanying_Family_Details-Date_of_Birth_Dependent5',
		ISNULL((SELECT code_desc FROM dbo.code AS code_27
			WHERE (code_value = dep5.cust_oth_dual_citizenship_country) AND (code_type = 'COUNTR')), '') AS 'Dual_Nationality_if_Applicable_Dependent5',
		ISNULL((SELECT code_desc FROM dbo.code_sirva AS code_32
			WHERE (code_value = cf.billing_center) AND code_type = 'BILCTR' AND (org_root_uid = a.org_root_uid)), '') AS 'CA-Billing_Center',
		Visa_Type = CASE WHEN ISNULL((SELECT MAX(VisaType) FROM form_7141_visa_immigration_permit_confirmation_visa_detail v2 where v2.cust_uid = a.Cust_UID AND Dependent_added_seq = 0), '') = '' 
						 THEN cf.cust_visa_type 
						 ELSE (SELECT MAX(VisaType) FROM form_7141_visa_immigration_permit_confirmation_visa_detail v2 where v2.cust_uid = a.Cust_UID AND Dependent_added_seq = 0) END 

from	dbo.rv_v2Customer AS a WITH (nolock)
		LEFT OUTER JOIN dbo.customer AS cu WITH (nolock) ON cu.cust_uid = a.cust_uid 
		LEFT OUTER JOIN dbo.form_0000_customer_05 AS c WITH (nolock) ON a.form_uid = c.form_uid
		LEFT OUTER JOIN dbo.form_0000_customer_05_custom AS cf WITH (nolock) ON c.form_uid = cf.form_uid
		LEFT OUTER JOIN	dbo.rv_v2form_0000_customer_05_phone AS rv_phone WITH (nolock) ON a.form_uid = rv_phone.form_uid
		LEFT OUTER JOIN dbo.cust_address AS oa WITH (nolock) ON a.cust_uid = oa.cust_uid AND oa.cust_address_type = 'ORIGIN'
		LEFT OUTER JOIN dbo.cust_address AS dw WITH (nolock) ON a.cust_uid = dw.cust_uid AND dw.cust_address_type = 'C203'
		LEFT OUTER JOIN dbo.form_7140_visa_immigration_initiation AS f7140 WITH (nolock) on f7140.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7141_visa_immigration_permit_confirmation AS f7141 WITH (nolock) on f7141.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7142_visa_immigration_application_filed AS f7142 WITH (nolock) on f7142.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7144_visa_immigration_documentation_received AS f7144 WITH (nolock) on f7144.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7145_visa_immigration_govtapprovalreceived AS f7145 WITH (nolock) on f7145.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7147_visa_immigration_details AS f7147 WITH (nolock) on f7147.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_7148_visa_immigration_signed_documents_rcvd AS f7148 WITH (nolock) on f7148.cust_uid = a.cust_uid
		LEFT OUTER JOIN dbo.form_0000_customer_05_dependents AS dep1 WITH (nolock) on dep1.cust_uid = a.cust_uid and dep1.seq = 1
		LEFT OUTER JOIN dbo.form_0000_customer_05_dependents AS dep2 WITH (nolock) on dep2.cust_uid = a.cust_uid and dep2.seq = 2
		LEFT OUTER JOIN dbo.form_0000_customer_05_dependents AS dep3 WITH (nolock) on dep3.cust_uid = a.cust_uid and dep3.seq = 3
		LEFT OUTER JOIN dbo.form_0000_customer_05_dependents AS dep4 WITH (nolock) on dep4.cust_uid = a.cust_uid and dep4.seq = 4
		LEFT OUTER JOIN dbo.form_0000_customer_05_dependents AS dep5 WITH (nolock) on dep5.cust_uid = a.cust_uid and dep5.seq = 5
		-- VSTS 13980
		LEFT OUTER JOIN dbo.form_7141_Visa_Immigration_Permit_Confirmation_Document_Details cdd WITH (NOLOCK) ON cdd.cust_uid = a.Cust_uid



GO


