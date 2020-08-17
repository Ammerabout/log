PROCEDURE Pass_File_By_Contract(contract_ IN VARCHAR2,
                                year_in_    IN VARCHAR2 )
IS
   
   PROCEDURE Ext(contract_ IN VARCHAR2,
                                   year_in_    IN VARCHAR2 )
   IS 
    category_id_  NUMBER;
    year_      VARCHAR2(10);
    CURSOR get_ IS 
    SELECT order_no,
           BUYER_CODE
     FROM purchase_order_tab tt
    WHERE CONTRACT  = contract_
      AND NVL(IF_PASS_FILE, 'FALSE') = 'FALSE'
      AND rowstate='Closed'
      --and contract_id is null
      AND EXISTS(SELECT 1
     FROM Purchase_Order_Hist_Tab t
    WHERE t.order_no = tt.order_no
      and t.hist_objstate = 'Closed'
      and to_char(date_entered, 'yyyy') = year_);
    CURSOR get_exist_ IS 
    SELECT category_id
       FROM business_category
      WHERE contract_id = contract_||'-'||year_;   
   BEGIN
    year_:=to_char(sysdate,'YYYY');
    OPEN get_exist_;
    FETCH get_exist_ INTO category_id_;
    CLOSE get_exist_;
    IF category_id_ ='' OR  category_id_ IS NULL  THEN 
      SELECT BUSINESS_CATEGORY_SEQ.NEXTVAL INTO category_id_ FROM dual;
      cp_contract_manage_main_api.Insert_Business_Category(  category_id_  ,
                                 contract_||'-'||year_   ,
                                 '',
                                 year_||'-'||COMPANY_SITE_API.Get_Description(contract_)||'-'||'采购订单' ,
                                 NULL  ,
                                 NULL ,
                                 COMPANY_SITE_API.Get_Description(contract_),
                                 sysdate,
                                 0,
                                 NULL ,
                                 sysdate,
                                 '国投甘肃小三峡发电有限公司'); 
    END IF ;
      FOR  rec_ IN get_ LOOP 
         Purch_Pass_File(rec_.order_no,
                             category_id_ ,
                             contract_  ,
                             rec_.order_no,
                             NULL  ,
                             sysdate,
                             PERSON_INFO_API.Get_Name(rec_.BUYER_CODE)  
                             ) ;
         
      END LOOP ;
   END Ext;

BEGIN
   General_SYS.Init_Method(Purchase_Order_API.lu_name_, 'Purchase_Order_API', 'Pass_File_By_Contract');
   Ext(contract_, year_in_);
END Pass_File_By_Contract;



PROCEDURE Purch_Pass_File(order_no_ IN VARCHAR2,
                          category_id_ IN NUMBER,
                          contract_    IN VARCHAR2 ,
                          contract_id_ IN VARCHAR2 DEFAULT NULL ,
                          dept_id_     IN VARCHAR2 DEFAULT NULL ,
                          sign_date_   IN DATE DEFAULT NULL ,
                          response_user_id_ IN VARCHAR2 DEFAULT NULL 
                          )
IS
   
   PROCEDURE Ext(order_no_ IN VARCHAR2,
                             category_id_ IN NUMBER,
                             contract_    IN VARCHAR2 ,
                             contract_id_ IN VARCHAR2 DEFAULT NULL ,
                             dept_id_     IN VARCHAR2 DEFAULT NULL ,
                             sign_date_   IN DATE DEFAULT NULL ,
                             response_user_id_ IN VARCHAR2 DEFAULT NULL 
                             ) 
   IS 
   count_      NUMBER ;
   parameter_attr_ VARCHAR2(3200);
   report_attr_     VARCHAR2(3200);
   rep_view_ VARCHAR2(200);
   rpt_file_   VARCHAR2(200);
   CURSOR get_ IS 
   ---采购订单
   SELECT Client_Sys.Get_Key_Reference('PurchaseOrder', 'ORDER_NO', ORDER_NO) key_ref,
          'PurchaseOrder' lu_name,
          '采购订单' lu_name_desc,
          to_char(rowversion, 'YYYYMMDDHH24MISS') objversion,
          rowid objid,
          Supplier_API.Get_Vendor_name(VENDOR_NO) || '采购订单:' || ORDER_NO contract_desc
     FROM purchase_order_tab
    WHERE order_no = order_no_
   --询价核准
   union all
   select Client_Sys.Get_Key_Reference('InquiryMain',
                                       'INQUIRY_NO',
                                       tt.INQUIRY_NO,
                                       'REVISION_NO',
                                       tt.REVISION_NO) key_ref,
          'InquiryMain' lu_name,
          '询价核准' lu_name_desc,
          to_char(rowversion, 'YYYYMMDDHH24MISS') objversion,
          rowid objid,
          PURCH_CONTENT || '询价核准:' || tt.INQUIRY_NO contract_desc
     from inquiry_main_tab tt
    WHERE exists (SELECT 1
             from quotation_line_tab ql
            WHERE ql.order_no = order_no_
              and ql.inquiry_no = tt.inquiry_no
              and ql.revision_no = tt.revision_no)
   --采购申请
   union all
   select Client_Sys.Get_Key_Reference('PurchaseRequisition',
                                       'REQUISITION_NO',
                                       requisition_no) key_ref,
          'PurchaseRequisition' lu_name,
          '采购申请' lu_name_desc,
          to_char(rowversion, 'YYYYMMDDHH24MISS') objversion,
          rowid objid,
          MARK_FOR || '采购申请:' || t.requisition_no contract_desc
     from purchase_requisition_tab t
    WHERE exists (SELECT 1
             from purchase_req_line_tab tt
            WHERE tt.order_no = order_no_
              and tt.requisition_no = t.requisition_no)
    UNION ALL 
    SELECT NULL  key_ref,
          'PurchaseReceipt' lu_name,
          '采购验收' lu_name_desc,
          objversion ,
          objid ,
          '采购验收单:' || t.order_no||'--'||t.approved_date contract_desc
     from Purchase_Receipt_In t
     WHERE order_no=order_no_;
     
    CURSOR get_exist_ IS 
    SELECT count(1)
    FROM  purchase_order_tab
    WHERE order_no = order_no_
      AND NVL(IF_PASS_FILE, 'FALSE') = 'FALSE';
   CURSOR get_doc(lu_name_  VARCHAR2 ,key_ref_  VARCHAR2 ) IS 
     select DOC_CLASS,
          DOC_NO,
          DOC_SHEET,
          DOC_REV,
          LU_NAME,
          KEY_REF,
          LOCATION_NAME,
          PATH,
          FILE_NAME,
          USER_FILE_NAME,
          FILE_TYPE,
          checked_in_date
     from ifsapp.APP_DOC_INFO
   WHERE lu_name=lu_name_
     AND KEY_REF=key_ref_;
     CURSOR get_report_(report_view_ VARCHAR2 ,rpt_file_ VARCHAR2) IS 
     SELECT report_copy_id, 
            report_description,
            report_view,
            business_view,
            relative_path,
            rpt_file
      FROM REPORT_CONFIGURATION
     WHERE upper(report_view)=upper(report_view_)
        AND upper(rpt_file) LIKE upper('%'||rpt_file_);
   CURSOR get_reprort_config(lu_name_ IN VARCHAR2) IS 
   SELECT *  FROM (
   select 'RPT_PURCHASE_RECEIPT_IN1_REP' reoport_view,
          'RPTPurchaseReceiptIn1.rpt' rpt_file,
          'PurchaseReceipt'       lu_name
   FROM dual
   union all 
   select 'PURCH_ORDER_PRINT_REP' reoport_view,
          'RPTPurchaseOrder.rpt' rpt_file,
          'PurchaseOrder'       lu_name
   FROM dual
   union all 
   select 'INQUIRY_MAIN_REPOR_REP' reoport_view,
          'InquiryMainReport.rpt' rpt_file,
          'InquiryMain'       lu_name
   FROM dual)
   WHERE lu_name=lu_name_;
   BEGIN 
   OPEN get_exist_;
   FETCH get_exist_ INTO count_;
   CLOSE get_exist_;
   IF count_>0 THEN 
      FOR rec_ IN get_ LOOP
         
         FOR file_ IN get_doc(rec_.lu_name,rec_.key_ref) LOOP 
            IF rec_.key_ref  IS NOT NULL THEN 
               cp_contract_manage_main_api.Insert_Business_Inter(null,
                                     null,
                                     null,
                                     null,
                                     null,  
                                     null,   
                                     null, 
                                     0,
                                     0,       
                                     file_.path, 
                                     file_.file_name,     
                                     file_.user_file_name,   
                                     file_.file_type, 
                                     '附件',     
                                     contract_id_,   
                                     '',
                                     rec_.contract_desc, 
                                     dept_id_,      
                                     rec_.key_ref,  
                                     Client_Sys.Get_Key_Reference('PurchaseOrder', 'ORDER_NO', ORDER_NO_),
                                     rec_.lu_name,       
                                     Supplier_API.Get_Vendor_name(PURCHASE_ORDER_API.Get_Vendor_No(ORDER_NO_)) || '采购订单:' || ORDER_NO_,
                                     response_user_id_,
                                     COMPANY_SITE_API.Get_Description(contract_),
                                     file_.checked_in_date,
                                     sign_date_,
                                     category_id_,
                                     '国投甘肃小三峡发电有限公司');
           END IF;
         END LOOP;
         FOR rec_rep_  IN get_reprort_config(rec_.lu_name) LOOP 
            parameter_attr_:=cp_contract_manage_main_api.Get_Parameter_Attr(rec_.objid,rec_.objversion,rec_rep_.reoport_view,rec_rep_.rpt_file);
   
            Client_SYS.Clear_Attr(report_attr_);
            Client_SYS.Add_To_Attr('REPORT_ID', rec_rep_.reoport_view, report_attr_);
   
            FOR rec_report_ IN get_report_(rec_rep_.reoport_view,rec_rep_.rpt_file) LOOP 
   
               cp_contract_manage_main_api.Insert_Business_Inter( rec_report_.report_copy_id,
                                       rec_report_.report_description,
                                       report_attr_,
                                       parameter_attr_,
                                       rec_report_.report_view,  
                                       rec_report_.rpt_file,   
                                       rec_report_.business_view, 
                                       0,
                                       0,       
                                       '\23\', 
                                       null,     
                                       null,   
                                       'ACROBAT', 
                                       '审批文档',     
                                       contract_id_,   
                                     '',
                                       rec_.contract_desc, 
                                       dept_id_,    
                                       rec_.key_ref,  
                                       Client_Sys.Get_Key_Reference('PurchaseOrder', 'ORDER_NO', ORDER_NO_),
                                       rec_.lu_name,       
                                       Supplier_API.Get_Vendor_name(PURCHASE_ORDER_API.Get_Vendor_No(ORDER_NO_)) || '采购订单:' || ORDER_NO_,
                                       response_user_id_,
                                       COMPANY_SITE_API.Get_Description(contract_),
                                       sysdate,
                                       sign_date_,
                                       category_id_,
                                     '国投甘肃小三峡发电有限公司');
            END LOOP ;
         END LOOP ;
         UPDATE purchase_order_tab
         SET IF_PASS_FILE='TRUE'
          WHERE order_no=order_no_;
      END LOOP ;
   END IF ;
   
   END Ext;

BEGIN
   General_SYS.Init_Method(Purchase_Order_API.lu_name_, 'Purchase_Order_API', 'Purch_Pass_File');
   Ext(order_no_, category_id_, contract_, contract_id_, dept_id_, sign_date_, response_user_id_);
END Purch_Pass_File;

