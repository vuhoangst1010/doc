--------------------------------------------------------
--  File created - Wednesday-September-29-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Function FUNC_TCKT_BC_HOANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "KTNB_TEST"."FUNC_TCKT_BC_HOANG" (
    p_mau_bao_cao     VARCHAR2,
    p_ma_dvhq         VARCHAR2,
    p_dvqhns_id       NUMBER,
    p_ma_tk           VARCHAR2,
    p_so_tk_id        VARCHAR2,
    p_loai_tien       VARCHAR2,
    p_nguon_kinh_phi  VARCHAR2,
    p_loai_kinh_phi   VARCHAR2,
    p_khoan           VARCHAR2,
    p_muc_tieu_muc    VARCHAR2,
    p_ngay_tu         DATE,
    p_ngay_den        DATE,
    p_nam             DATE,
    p_ma_kbnh         NUMBER,
    p_doi_tuong       NUMBER
) RETURN tckt_bc_hoang_table_type
    PIPELINED
IS

    PRAGMA autonomous_transaction;
    TYPE ref0 IS REF CURSOR;
    mycursor  ref0;
    out_rec   tckt_bc_hoang_type := tckt_bc_hoang_type(NULL, NULL, NULL, NULL, NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    0,
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    0,
                                                    0,
                                                    NULL,
                                                    0,
                                                    NULL,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    NULL,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    NULL,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0,
                                                    0);
BEGIN
    DELETE tbr_tc_bc_001;

    CASE
        WHEN ( p_mau_bao_cao = 'TCKT_BC_03' ) THEN
            PKG_BC_TCKT_001.prc_so_chi_tiet_cac_tai_khoan(p_ma_dvhq,
                                                           p_ma_tk,
                                                           p_ngay_tu,
                                                           p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_04' ) THEN
            PKG_BC_TCKT_001.prc_so_quy_tien_mat(p_ma_dvhq, p_ngay_tu,
                                                 p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_05' ) THEN
            PKG_BC_TCKT_001.prc_so_tien_gui_ngan_hang_kho_bac(p_ma_dvhq,
                                                               p_ma_tk,
                                                               p_so_tk_id,
                                                               p_ngay_tu,
                                                               p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_06' ) THEN
            PKG_BC_TCKT_001.prc_so_theo_doi_tien_mat_tien_gui_bang_ngoai_te(p_ma_dvhq,
                                                                             p_ma_tk,
                                                                             p_loai_tien,
                                                                             p_ngay_tu,
                                                                             p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_15' ) THEN
            PKG_BC_TCKT_001.prc_so_chi_tiet_cac_khoan_tam_thu(p_ma_dvhq,
                                                               p_ma_tk,
                                                               p_ngay_tu,
                                                               p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_16' ) THEN
            PKG_BC_TCKT_001.prc_so_chi_tiet_chi_hoat_dong(p_ma_dvhq, p_nguon_kinh_phi, p_loai_kinh_phi, p_khoan,
                                                           p_muc_tieu_muc,
                                                           p_ngay_tu,
                                                           p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_17' ) THEN
            PKG_BC_TCKT_001.prc_so_chi_phi_san_xuat_kinh_doanh(p_ma_dvhq,
                                                                p_ma_tk,
                                                                p_ngay_tu,
                                                                p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_18' ) THEN
            PKG_BC_TCKT_001.prc_so_chi_tiet_chi_phi_hoat_dong(p_ma_dvhq,
                                                               p_ma_tk,
                                                               p_ngay_tu,
                                                               p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_30' ) THEN
            pkg_bc_tckt_hoang.prc_bao_cao_bang_tinh_hinh_thuc_hien_du_toan_KPTX(p_ma_dvhq, p_nam,
                                                                          p_ma_kbnh);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_32' ) THEN
            PKG_BC_TCKT_001.prc_bang_doi_chieu_tai_khoan_tien_gui(p_ma_dvhq,
                                                                   p_dvqhns_id,
                                                                   p_ngay_tu,
                                                                   p_ngay_den);
        WHEN ( p_mau_bao_cao = 'TCKT_BC_48' ) THEN
            pkg_bc_tckt_hoang.prc_bao_cao_bang_can_doi_so_phat_sinh(p_ma_dvhq, p_nam);

        WHEN ( p_mau_bao_cao = 'TCKT_BC_71' ) THEN
            PKG_BC_TCKT_001.prc_bao_cao_bang_tinh_hinh_thuc_hien_du_toan(p_ma_dvhq, p_ngay_den,
                                                                          p_doi_tuong);
       
    END CASE; 

    COMMIT;
    OPEN mycursor FOR SELECT
                          *
                      FROM
                          tbr_tc_bc_001;

    LOOP
        FETCH mycursor INTO
            out_rec.stt,
            out_rec.ma_but_toan,
            out_rec.ma_loai_ct,
            out_rec.ma_loai_nv,
            out_rec.so_ct,
            out_rec.so_but_toan,
            out_rec.dien_giai,
            out_rec.tk_doi_ung,
            out_rec.ma_dvhq,
            out_rec.ky_ke_toan,
            out_rec.ma_nam_ns,
            out_rec.ngay_ct,
            out_rec.ngay_ht,
            out_rec.dt_id,
            out_rec.ma_tk_no,
            out_rec.ma_tk_co,
            out_rec.loai_tk,
            out_rec.tkdt_nh_id,
            out_rec.ma_tk,
            out_rec.ma_tk_id,
            out_rec.ten_tk,
            out_rec.st_no,
            out_rec.st_co,
            out_rec.st_ton,
            out_rec.ty_gia,
            out_rec.loai_tien,
            out_rec.so_tien_vnd_no,
            out_rec.so_tien_vnd_co,
            out_rec.so_tien_vnd_ton,
            out_rec.so_tien_chenh_lech,
            out_rec.so_du_dk_no,
            out_rec.so_du_dk_co,
            out_rec.so_phat_sinh_tk_no,
            out_rec.so_phat_sinh_tk_co,
            out_rec.so_luy_ke_no,
            out_rec.so_luy_ke_co,
            out_rec.so_du_ck_no,
            out_rec.so_du_ck_co,
            out_rec.tam_ung,
            out_rec.thanh_toan_tam_ung,
            out_rec.so_tien_thu,
            out_rec.so_tien_chi,
            out_rec.so_tien_ton,
            out_rec.so_tien_gui_vao,
            out_rec.so_tien_rut_ra,
            out_rec.so_tien_con_lai,
            out_rec.tkdt_id,
            out_rec.so_du_dn_no,
            out_rec.so_du_dn_co,
            out_rec.dcsddn_no,
            out_rec.dcsddn_co,
            out_rec.so_du_cn_no,
            out_rec.so_du_cn_co,
            out_rec.ma_nguon_ns,
            out_rec.ma_nguon_kp,
            out_rec.ma_loai_kp,
            out_rec.chuong,
            out_rec.khoan,
            out_rec.mtm_id,
            out_rec.ndc_id,
            out_rec.ghi_chu,
            out_rec.flag_sequence,
            out_rec.flag_data_type,
            out_rec.thuoc_tinh_1,
            out_rec.thuoc_tinh_2,
            out_rec.thuoc_tinh_3,
            out_rec.thuoc_tinh_4,
            out_rec.thuoc_tinh_5,
            out_rec.thuoc_tinh_6,
            out_rec.thuoc_tinh_7,
            out_rec.thuoc_tinh_8,
            out_rec.thuoc_tinh_9,
            out_rec.thuoc_tinh_10,
            out_rec.thuoc_tinh_11,
            out_rec.thuoc_tinh_12,
            out_rec.thuoc_tinh_13,
            out_rec.thuoc_tinh_14,
            out_rec.thuoc_tinh_15,
            out_rec.thuoc_tinh_16,
            out_rec.thuoc_tinh_17,
            out_rec.thuoc_tinh_18,
            out_rec.thuoc_tinh_19,
            out_rec.thuoc_tinh_20;

        EXIT WHEN mycursor%notfound;
        PIPE ROW ( out_rec );
    END LOOP;

    CLOSE mycursor;
    /*END IF;*/ RETURN;
END;

/
