create PACKAGE BODY pkg_bc_tckt_hoang AS

    --TCKT_BC_03 – So chi tiet cac tai khoan
    PROCEDURE prc_so_chi_tiet_cac_tai_khoan(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_du_dk_no,
                                   so_du_dk_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               dldk.ma_tk,
               decode(dldk.loai_tai_khoan, 1, dldk.so_tien, 3,
                      decode(dldk.so_tien - abs(dldk.so_tien), 0, dldk.so_tien, 0))   so_du_dk_no,
               decode(dldk.loai_tai_khoan, 2, abs(dldk.so_tien), 3,
                      decode(dldk.so_tien + abs(dldk.so_tien), 0, abs(dldk.so_tien))) so_du_dk_co,
               '002',
               'B'
        FROM (
                 SELECT ht.ma_tk                                                        ma_tk,
                        ht.loai_tai_khoan                                               loai_tai_khoan,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                 FROM tbd_tc_ht ht
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ht.ma_tk = nvl(p_ma_tk, '00')
                   AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
                 GROUP BY ht.ma_tk,
                          ht.loai_tai_khoan
             ) dldk;

        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ma_tk,
                                   tk_doi_ung,
                                   loai_tk,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ma_tk,
               ht.ma_tk_doi_ung  tk_doi_ung,
               ht.loai_tai_khoan loai_tk,
               ht.so_tien_vnd_no,
               ht.so_tien_vnd_co,
               '003'             thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '02/01/1900',
                                                                                                                  'DD/MM/YYYY'));


        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT '- Cộng phát sinh trong kỳ:' dien_giai,
               nvl(SUM(nvl(dl.so_tien_vnd_no, 0)), 0),
               nvl(SUM(nvl(dl.so_tien_vnd_co, 0)), 0),
               '004'                        thuoc_tinh_1,
               'B'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';


        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT '- Cộng lũy kế từ đầu năm:'    dien_giai,
               ht.ma_tk,
               SUM(nvl(ht.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien_vnd_co,
               '005'                          thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;

        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_du_dk_no,
                                   so_du_dk_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT dldk.dien_giai,
               dldk.ma_tk,
               decode(dldk.loai_tai_khoan, 1, dldk.so_tien, 3,
                      decode(dldk.so_tien - abs(dldk.so_tien), 0, dldk.so_tien, 0)) so_du_dk_no,
               decode(dldk.loai_tai_khoan, 2, abs(dldk.so_tien), 3,
                      decode(dldk.so_tien + abs(dldk.so_tien), 0, abs(dldk.so_tien),
                             0))                                                    so_du_dk_co,
               '006',
               'B'
        FROM (
                 SELECT 'Số dư cuối kỳ:'                                                dien_giai,
                        ht.ma_tk                                                        ma_tk,
                        ht.loai_tai_khoan                                               loai_tai_khoan,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                 FROM tbd_tc_ht ht
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ht.ma_tk = nvl(p_ma_tk, '00')
                   AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
                 GROUP BY ht.ma_tk,
                          ht.loai_tai_khoan
             ) dldk;

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_du_dk_no,
                                   so_du_dk_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               '0',
               '0',
               '0',
               '002',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '002'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT '- Cộng lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_du_dk_no,
                                   so_du_dk_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:',
               '0',
               '0',
               '0',
               '006',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '006'
            );

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_04 - Sổ quỹ tiền mặt
    -- Người sửa: HoangV
    -- Ngày sửa: 17/06/2021
    */
    PROCEDURE prc_so_quy_tien_mat(
        p_ma_dvhq VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        prc_so_chi_tiet_cac_tai_khoan(p_ma_dvhq, '11110000', p_ngay_tu, p_ngay_den);
    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_05 - Sổ tiền gửi ngân hàng, kho bạc
    -- Người sửa: HoangV
    -- Ngày sửa: 18/06/2021
    */
    PROCEDURE prc_so_tien_gui_ngan_hang_kho_bac(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_so_tk_id VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
        p_ma_tk_cat VARCHAR2(50);
    BEGIN
        SELECT TRIM(TRAILING '0' FROM nvl(p_ma_tk, '00'))
        INTO p_ma_tk_cat
        FROM dual;

        p_ma_tk_cat := '^' || p_ma_tk_cat;
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_con_lai,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:' dien_giai,
               ht.ma_tk        ma_tk,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) > 0 THEN
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)))
                           END
                   END         so_tien_con_lai,
               '002'           thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE REGEXP_LIKE(ht.ma_tk,
                          p_ma_tk_cat)
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.tkdt_nh_id = nvl(p_so_tk_id, '00')
          AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk,
                 ht.loai_tai_khoan;

        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ma_tk,
                                   so_tien_gui_vao,
                                   so_tien_rut_ra,
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ma_tk,
               ht.so_tien_vnd_no,
               ht.so_tien_vnd_co,
               '003' thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE REGEXP_LIKE(ht.ma_tk,
                          p_ma_tk_cat)
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.tkdt_nh_id = nvl(p_so_tk_id, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));


        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_gui_vao,
                                   so_tien_rut_ra,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               nvl(SUM(nvl(dl.so_tien_gui_vao, 0)), 0),
               nvl(SUM(nvl(dl.so_tien_rut_ra, 0)), 0),
               '004'                      thuoc_tinh_1,
               'B'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';


        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_gui_vao,
                                   so_tien_rut_ra,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:'      dien_giai,
               ht.ma_tk,
               SUM(nvl(ht.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien_vnd_co,
               '005'                          thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE REGEXP_LIKE(ht.ma_tk,
                          p_ma_tk_cat)
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.tkdt_nh_id = nvl(p_so_tk_id, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;
        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_con_lai,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:' dien_giai,
               ht.ma_tk         ma_tk,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) > 0 THEN
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)))
                           END
                   END          so_tien_con_lai,
               '006'            thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE REGEXP_LIKE(ht.ma_tk,
                          p_ma_tk_cat)
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.tkdt_nh_id = nvl(p_so_tk_id, '00')
          AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk,
                 ht.loai_tai_khoan;

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_con_lai,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               '0',
               '0',
               '002',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '002'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_gui_vao,
                                   so_tien_rut_ra,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   so_tien_con_lai,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:',
               '0',
               '0',
               '006',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '006'
            );

    END;

    /*
    -- Mã/Tên chức năng: TCKT_BC_06 – Sổ chi tiết quỹ tiền mặt và TGNH bằng ngoại tệ
    -- Người sửa: HoangV
    -- Ngày sửa: 17/06/2021
    */
    PROCEDURE prc_so_theo_doi_tien_mat_tien_gui_bang_ngoai_te(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_loai_tien VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_ton,
                                   so_tien_vnd_ton,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:' dien_giai,
               ht.ma_tk        ma_tk,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.st_co, 0)) - SUM(nvl(ht.st_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)) > 0 THEN
                               SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0))
                           WHEN SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)))
                           END
                   END         st_ton,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) > 0 THEN
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)))
                           END
                   END         so_tien_vnd_ton,
               '002'           thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.loai_tien = nvl(p_loai_tien, 'VND')
          AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk,
                 ht.loai_tai_khoan;

        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ty_gia,
                                   ma_tk,
                                   loai_tk,
                                   st_no,
                                   so_tien_vnd_no,
                                   st_co,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ty_gia,
               ht.ma_tk,
               ht.loai_tai_khoan loai_tk,
               ht.st_no,
               ht.so_tien_vnd_no,
               ht.st_co,
               ht.so_tien_vnd_co,
               '003'             thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.loai_tien = nvl(p_loai_tien, 'VND')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));

        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   st_no,
                                   so_tien_vnd_no,
                                   st_co,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               nvl(SUM(nvl(dl.st_no, 0)), 0),
               nvl(SUM(nvl(dl.so_tien_vnd_no, 0)), 0),
               nvl(SUM(nvl(dl.st_co, 0)), 0),
               nvl(SUM(nvl(dl.so_tien_vnd_co, 0)), 0),
               '004'                      thuoc_tinh_1,
               'B'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';


        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_no,
                                   so_tien_vnd_no,
                                   st_co,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:' dien_giai,
               ht.ma_tk,
               SUM(nvl(ht.st_no, 0)),
               SUM(nvl(ht.so_tien_vnd_no, 0)),
               SUM(nvl(ht.st_co, 0)),
               SUM(nvl(ht.so_tien_vnd_co, 0)),
               '005'                     thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.loai_tien = nvl(p_loai_tien, 'VND')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;

        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_ton,
                                   so_tien_vnd_ton,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:' dien_giai,
               ht.ma_tk         ma_tk,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.st_co, 0)) - SUM(nvl(ht.st_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)) > 0 THEN
                               SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0))
                           WHEN SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.st_no, 0)) - SUM(nvl(ht.st_co, 0)))
                           END
                   END          st_ton,
               CASE
                   WHEN ht.loai_tai_khoan = 1 THEN
                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                   WHEN ht.loai_tai_khoan = 2 THEN
                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))
                   WHEN ht.loai_tai_khoan = 3 THEN
                       CASE
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) > 0 THEN
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))
                           WHEN SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) < 0 THEN
                               abs(SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)))
                           END
                   END          so_tien_vnd_ton,
               '006'            thuoc_tinh_1,
               'B'
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.loai_tien = nvl(p_loai_tien, 'VND')
          AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk,
                 ht.loai_tai_khoan;

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_ton,
                                   so_tien_vnd_ton,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               '0',
               '0',
               '0',
               '002',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '002'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_no,
                                   so_tien_vnd_no,
                                   st_co,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   st_ton,
                                   so_tien_vnd_ton,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:',
               '0',
               '0',
               '0',
               '006',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '006'
            );

    END prc_so_theo_doi_tien_mat_tien_gui_bang_ngoai_te;

    /*
    -- Mã/Tên chức năng: TCKT_BC_15 – Sổ chi tiết các khoản tạm thu
    -- Người sửa: HoangV
    -- Ngày sửa: 17/06/2021
    */
    PROCEDURE prc_so_chi_tiet_cac_khoan_tam_thu(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:'                                                 dien_giai,
               ht.ma_tk                                                        ma_tk,
               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)) thuoc_tinh_11,
               '002'                                                           thuoc_tinh_1,
               'B'                                                             thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;

        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_12, --Nop ngan sach
                                   thuoc_tinh_13, --Chuyen sang cac khoan nhan truoc chua ghi thu
                                   thuoc_tinh_14, --Chuyen sang doan thu
                                   thuoc_tinh_15, --Nop cap tren
                                   thuoc_tinh_16, --Nop cac doi tuong khac(neu co)
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ma_tk,
               ht.so_tien_vnd_co thuoc_tinh_11,
               CASE
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '333'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   END           thuoc_tinh_12,
               CASE
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '366'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   END           thuoc_tinh_13,
               CASE
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '511'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '512'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   END           thuoc_tinh_14,
               CASE
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '336'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '338'
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   END           thuoc_tinh_15,
               CASE
                   WHEN NOT REGEXP_LIKE(ht.ma_tk_doi_ung, '^333|^366|^511|^512|^514|^336|^338')
                       AND ht.so_tien_vnd_co IS NULL THEN
                       nvl(ht.so_tien_vnd_no, 0)
                   END           thuoc_tinh_16,
               '003'             thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));
        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_12, --Nop ngan sach
                                   thuoc_tinh_13, --Chuyen sang cac khoan nhan truoc chua ghi thu
                                   thuoc_tinh_14, --Chuyen sang doan thu
                                   thuoc_tinh_15, --Nop cap tren
                                   thuoc_tinh_16, --Nop cac doi tuong khac(neu co)
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               nvl(SUM(nvl(dl.thuoc_tinh_11, 0)), 0),
               nvl(SUM(nvl(dl.thuoc_tinh_12, 0)), 0),
               nvl(SUM(nvl(dl.thuoc_tinh_13, 0)), 0),
               nvl(SUM(nvl(dl.thuoc_tinh_14, 0)), 0),
               nvl(SUM(nvl(dl.thuoc_tinh_15, 0)), 0),
               nvl(SUM(nvl(dl.thuoc_tinh_16, 0)), 0),
               '004'                      thuoc_tinh_1,
               'B'                        thuoc_tinh_2
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';
        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_12, --Nop ngan sach
                                   thuoc_tinh_13, --Chuyen sang cac khoan nhan truoc chua ghi thu
                                   thuoc_tinh_14, --Chuyen sang doan thu
                                   thuoc_tinh_15, --Nop cap tren
                                   thuoc_tinh_16, --Nop cac doi tuong khac(neu co)
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:' dien_giai,
               ma_tk,
               SUM(nvl(thuoc_tinh_11, 0)),
               SUM(nvl(thuoc_tinh_12, 0)),
               SUM(nvl(thuoc_tinh_13, 0)),
               SUM(nvl(thuoc_tinh_14, 0)),
               SUM(nvl(thuoc_tinh_15, 0)),
               SUM(nvl(thuoc_tinh_16, 0)),
               '005'                     thuoc_tinh_1,
               'B'                       thuoc_tinh_2
        FROM (
                 SELECT ht.ma_tk,
                        SUM(nvl(ht.so_tien_vnd_co, 0)) thuoc_tinh_11,
                        CASE
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '333'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                SUM(nvl(ht.so_tien_vnd_no, 0))
                            END                        thuoc_tinh_12,
                        CASE
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '366'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                SUM(nvl(ht.so_tien_vnd_no, 0))
                            END                        thuoc_tinh_13,
                        CASE
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '511'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                SUM(nvl(ht.so_tien_vnd_no, 0))
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '512'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                SUM(nvl(ht.so_tien_vnd_no, 0))
                            END                        thuoc_tinh_14,
                        CASE
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '336'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                nvl(ht.so_tien_vnd_no, 0)
                            WHEN substr(ht.ma_tk_doi_ung, 1, 3) LIKE '338'
                                AND ht.so_tien_vnd_co IS NULL THEN
                                nvl(ht.so_tien_vnd_no, 0)
                            END                        thuoc_tinh_15,
                        CASE
                            WHEN NOT REGEXP_LIKE(ht.ma_tk_doi_ung, '^333|^366|^511|^512|^514|^336|^338')
                                AND ht.so_tien_vnd_co IS NULL THEN
                                nvl(ht.so_tien_vnd_no, 0)
                            END                        thuoc_tinh_16
                 FROM tbd_tc_ht ht
                 WHERE ht.ma_tk = nvl(p_ma_tk, '00')
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND
                     nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
                 GROUP BY ht.ma_tk,
                          ht.ma_tk_doi_ung,
                          ht.so_tien_vnd_co,
                          ht.so_tien_vnd_no,
                          '^333|^366|^511|^512|^514|^336|^338'
             )
        GROUP BY ma_tk;
        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:'                                                dien_giai,
               ht.ma_tk                                                        ma_tk,
               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)) thuoc_tinh_11,
               '006'                                                           thuoc_tinh_1,
               'B'                                                             thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk = nvl(p_ma_tk, '00')
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               '0',
               '0',
               '002',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '002'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_12, --Nop ngan sach
                                   thuoc_tinh_13, --Chuyen sang cac khoan nhan truoc chua ghi thu
                                   thuoc_tinh_14, --Chuyen sang doan thu
                                   thuoc_tinh_15, --Nop cap tren
                                   thuoc_tinh_16, --Nop cac doi tuong khac(neu co)
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '0',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_11, --Tong so tam thu
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:',
               '0',
               '0',
               '006',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '006'
            );

    END;

    /*
    -- Mã/Tên chức năng: TCKT_BC_16 – Sổ chi tiết chi hoạt động
    -- Người sửa: HoangV
    -- Ngày sửa: 17/06/2021
    */
    PROCEDURE prc_so_chi_tiet_chi_hoat_dong(
        p_ma_dvhq VARCHAR2,
        p_nguon_kinh_phi VARCHAR2,
        p_loai_kinh_phi VARCHAR2,
        p_khoan VARCHAR2,
        p_muc_tieu_muc VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:'                                                 dien_giai,
               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) thuoc_tinh_11,
               '002'                                                           thuoc_tinh_1,
               'B'                                                             thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk LIKE '611%'
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND (p_nguon_kinh_phi IS NULL
            OR p_nguon_kinh_phi = ht.ma_nguon_kp)
          AND (p_loai_kinh_phi IS NULL
            OR p_loai_kinh_phi = ht.ma_loai_kp)
          AND (p_khoan IS NULL
            OR p_khoan = ht.khoan)
          AND (p_muc_tieu_muc IS NULL
            OR p_muc_tieu_muc = ht.mtm_id)
          AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('02/01/1900', 'DD/MM/YYYY'));
        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ma_tk,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ma_tk,
               ht.so_tien_vnd_no,
               ht.so_tien_vnd_co,
               '003' thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk LIKE '611%'
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND (p_nguon_kinh_phi IS NULL
            OR p_nguon_kinh_phi = ht.ma_nguon_kp)
          AND (p_loai_kinh_phi IS NULL
            OR p_loai_kinh_phi = ht.ma_loai_kp)
          AND (p_khoan IS NULL
            OR p_khoan = ht.khoan)
          AND (p_muc_tieu_muc IS NULL
            OR p_muc_tieu_muc = ht.mtm_id)
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));
        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               nvl(SUM(nvl(dl.so_tien_vnd_no, 0)), 0),
               nvl(SUM(nvl(dl.so_tien_vnd_co, 0)), 0),
               '004'                      thuoc_tinh_1,
               'B'                        thuoc_tinh_2
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';
        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:' dien_giai,
               SUM(nvl(ht.so_tien_vnd_no, 0)),
               SUM(nvl(ht.so_tien_vnd_co, 0)),
               '005'                     thuoc_tinh_1,
               'B'                       thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk LIKE '611%'
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND (p_nguon_kinh_phi IS NULL
            OR p_nguon_kinh_phi = ht.ma_nguon_kp)
          AND (p_loai_kinh_phi IS NULL
            OR p_loai_kinh_phi = ht.ma_loai_kp)
          AND (p_khoan IS NULL
            OR p_khoan = ht.khoan)
          AND (p_muc_tieu_muc IS NULL
            OR p_muc_tieu_muc = ht.mtm_id)
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'));
        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:' dien_giai,
               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
               '006'            thuoc_tinh_1,
               'B'              thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_tk LIKE '611%'
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND (p_nguon_kinh_phi IS NULL
            OR p_nguon_kinh_phi = ht.ma_nguon_kp)
          AND (p_loai_kinh_phi IS NULL
            OR p_loai_kinh_phi = ht.ma_loai_kp)
          AND (p_khoan IS NULL
            OR p_khoan = ht.khoan)
          AND (p_muc_tieu_muc IS NULL
            OR p_muc_tieu_muc = ht.mtm_id)
          AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'));

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư đầu kỳ:',
               '0',
               '002',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '002'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng lũy kế từ đầu năm:',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   so_tien_vnd_no,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Số dư cuối kỳ:',
               '0',
               '006',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '006'
            );

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_17 – Sổ chi phí sản xuất, kinh doanh (Hoặc đầu tư XDCB)
    -- Người sửa: HoangV
    -- Ngày sửa: 17/06/2021
    */
    PROCEDURE prc_so_chi_phi_san_xuat_kinh_doanh(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư đầu kỳ:'                                                                    dien_giai,
--                ht.ma_tk                                                                           ma_tk,
--                SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))                    thuoc_tinh_11,
--                '002'                                                                              thuoc_tinh_1,
--                'B'                                                                                thuoc_tinh_2
--            FROM
--                tbd_tc_ht ht
--            WHERE
--                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                AND ht.ma_tk = nvl(p_ma_tk, '00')
--                AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
--            GROUP BY
--                ht.ma_tk;
        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Hoat dong in, phat hanh an pham 6321
                                   thuoc_tinh_13, --Hoat dong quang cao 6322
                                   thuoc_tinh_14, --Hoat dong ban an chi 6323
                                   thuoc_tinh_15, --Hoat dong dich vu khac 6328
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.dien_giai,
               ht.ma_tk,
               CASE
                   WHEN substr(nvl(p_ma_tk, '00'), 1, 4) = '6321' THEN
                       ht.so_tien_vnd_no
                   END           thuoc_tinh_12,
               CASE
                   WHEN substr(nvl(p_ma_tk, '00'), 1, 4) = '6322' THEN
                       ht.so_tien_vnd_no
                   END           thuoc_tinh_13,
               CASE
                   WHEN substr(nvl(p_ma_tk, '00'), 1, 4) = '6323' THEN
                       ht.so_tien_vnd_no
                   END           thuoc_tinh_14,
               CASE
                   WHEN substr(nvl(p_ma_tk, '00'), 1, 4) = '6328' THEN
                       ht.so_tien_vnd_no
                   END           thuoc_tinh_15,
               ht.so_tien_vnd_co thuoc_tinh_16,
               '003'             thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));
        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   thuoc_tinh_12, --Hoat dong in, phat hanh an pham 6321
                                   thuoc_tinh_13, --Hoat dong quang cao 6322
                                   thuoc_tinh_14, --Hoat dong ban an chi 6323
                                   thuoc_tinh_15, --Hoat dong dich vu khac 6328
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               '004'                      thuoc_tinh_1,
               'B'                        thuoc_tinh_2
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';
        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Hoat dong in, phat hanh an pham 6321
                                   thuoc_tinh_13, --Hoat dong quang cao 6322
                                   thuoc_tinh_14, --Hoat dong ban an chi 6323
                                   thuoc_tinh_15, --Hoat dong dich vu khac 6328
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Lũy kế từ đầu năm:'                                                                dien_giai,
               ht.ma_tk,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 1, 4), '6321', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_12,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 1, 4), '6322', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_13,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 1, 4), '6323', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_14,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 1, 4), '6328', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_15,
               SUM(nvl(ht.so_tien_vnd_co, 0))                                                      thuoc_tinh_16,
               '005'                                                                               thuoc_tinh_1,
               'B'                                                                                 thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;
        --Lay so du cuoi ky
--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư cuối kỳ:'                                                                   dien_giai,
--                ht.ma_tk                                                                           ma_tk,
--                SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))                    thuoc_tinh_11,
--                '006'                                                                              thuoc_tinh_1,
--                'B'                                                                                thuoc_tinh_2
--            FROM
--                tbd_tc_ht ht
--            WHERE
--                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                AND ht.ma_tk = nvl(p_ma_tk, '00')
--                AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
--            GROUP BY
--                ht.ma_tk;
--
--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư đầu kỳ:',
--                '0',
--                '0',
--                '002',
--                'B'
--            FROM
--                dual
--            WHERE
--                NOT EXISTS (
--                    SELECT
--                        *
--                    FROM
--                        tbr_tc_bc_001
--                    WHERE
--                        thuoc_tinh_1 = '002'
--                );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Hoat dong in, phat hanh an pham 6321
                                   thuoc_tinh_13, --Hoat dong quang cao 6322
                                   thuoc_tinh_14, --Hoat dong ban an chi 6323
                                   thuoc_tinh_15, --Hoat dong dich vu khac 6328
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        --        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư cuối kỳ:',
--                '0',
--                '0',
--                '006',
--                'B'
--            FROM
--                dual
--            WHERE
--                NOT EXISTS (
--                    SELECT
--                        *
--                    FROM
--                        tbr_tc_bc_001
--                    WHERE
--                        thuoc_tinh_1 = '006'
--                );

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_18 - Sổ chi tiết chi phí
    -- Người sửa: HoangV
    -- Ngày sửa: 22/06/2021
    */
    PROCEDURE prc_so_chi_tiet_chi_phi_hoat_dong(
        p_ma_dvhq VARCHAR2,
        p_ma_tk VARCHAR2,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN
        --Lay so du dau ky
--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư đầu kỳ:'                                                                    dien_giai,
--                ht.ma_tk                                                                           ma_tk,
--                SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))                    thuoc_tinh_11,
--                '002'                                                                              thuoc_tinh_1,
--                'B'                                                                                thuoc_tinh_2
--            FROM
--                tbd_tc_ht ht
--            WHERE
--                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                AND ht.ma_tk = nvl(p_ma_tk, '00')
--                AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
--            GROUP BY
--                ht.ma_tk;
        --Lay du lieu trong ky
        INSERT INTO tbr_tc_bc_001 (ngay_ht,
                                   so_ct,
                                   ngay_ct,
                                   so_but_toan,
                                   dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Chi tien luong, tien cong va chi khac cho nhan vien  61x1xxxx 
                                   thuoc_tinh_13, --Chi vat tu, cong cu va dich vu da su dung 61x2xxxx 
                                   thuoc_tinh_14, --chi khau hao/ hao mon TSCD 61x3xxxx 
                                   thuoc_tinh_15, --Chi khac 61x8xxxx 
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1)
        SELECT ht.ngay_ht,
               ht.so_ct,
               ht.ngay_ct,
               ht.ma_but_toan,
               ht.dien_giai,
               ht.ma_tk,
               decode(substr(nvl(p_ma_tk, '00'), 4, 1), '1', ht.so_tien_vnd_no) thuoc_tinh_12,
               decode(substr(nvl(p_ma_tk, '00'), 4, 1), '2', ht.so_tien_vnd_no) thuoc_tinh_13,
               decode(substr(nvl(p_ma_tk, '00'), 4, 1), '3', ht.so_tien_vnd_no) thuoc_tinh_14,
               decode(substr(nvl(p_ma_tk, '00'), 4, 1), '8', ht.so_tien_vnd_no) thuoc_tinh_15,
               ht.so_tien_vnd_co                                                thuoc_tinh_16,
               '003'                                                            thuoc_tinh_1
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'));
        --Cong phat sinh trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   thuoc_tinh_12, --Chi tien luong, tien cong va chi khac cho nhan vien  61x1xxxx 
                                   thuoc_tinh_13, --Chi vat tu, cong cu va dich vu da su dung 61x2xxxx 
                                   thuoc_tinh_14, --chi khau hao/ hao mon TSCD 61x3xxxx 
                                   thuoc_tinh_15, --Chi khac 61x8xxxx
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng phát sinh trong kỳ:' dien_giai,
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               '004'                      thuoc_tinh_1,
               'B'                        thuoc_tinh_2
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '003';
        --Lay cong luy ke tu dau nam
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Chi tien luong, tien cong va chi khac cho nhan vien  61x1xxxx 
                                   thuoc_tinh_13, --Chi vat tu, cong cu va dich vu da su dung 61x2xxxx 
                                   thuoc_tinh_14, --chi khau hao/ hao mon TSCD 61x3xxxx 
                                   thuoc_tinh_15, --Chi khac 61x8xxxx
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Lũy kế từ đầu năm:'                                                             dien_giai,
               ht.ma_tk,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 4, 1), '1', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_12,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 4, 1), '2', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_13,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 4, 1), '3', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_14,
               SUM(decode(substr(nvl(p_ma_tk, '00'), 4, 1), '8', nvl(ht.so_tien_vnd_no, 0), 0)) thuoc_tinh_15,
               SUM(nvl(ht.so_tien_vnd_co, 0))                                                   thuoc_tinh_16,
               '005'                                                                            thuoc_tinh_1,
               'B'                                                                              thuoc_tinh_2
        FROM tbd_tc_ht ht
        WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk = nvl(p_ma_tk, '00')
          AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')), 'YEAR') AND nvl(
                p_ngay_den,
                TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.ma_tk;
        --Lay so du cuoi ky
--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư cuối kỳ:'                                                                   dien_giai,
--                ht.ma_tk                                                                           ma_tk,
--                SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0))                    thuoc_tinh_11,
--                '006'                                                                              thuoc_tinh_1,
--                'B'                                                                                thuoc_tinh_2
--            FROM
--                tbd_tc_ht ht
--            WHERE
--                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                AND ht.ma_tk = nvl(p_ma_tk, '00')
--                AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
--            GROUP BY
--                ht.ma_tk;

--        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư đầu kỳ:',
--                '0',
--                '0',
--                '002',
--                'B'
--            FROM
--                dual
--            WHERE
--                NOT EXISTS (
--                    SELECT
--                        *
--                    FROM
--                        tbr_tc_bc_001
--                    WHERE
--                        thuoc_tinh_1 = '002'
--                );

        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   ma_tk,
                                   thuoc_tinh_12, --Chi tien luong, tien cong va chi khac cho nhan vien  61x1xxxx 
                                   thuoc_tinh_13, --Chi vat tu, cong cu va dich vu da su dung 61x2xxxx 
                                   thuoc_tinh_14, --chi khau hao/ hao mon TSCD 61x3xxxx 
                                   thuoc_tinh_15, --Chi khac 61x8xxxx
                                   thuoc_tinh_16, --So phat sinh co
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Lũy kế từ đầu năm:',
               '0',
               '0',
               '0',
               '0',
               '0',
               '0',
               '005',
               'B'
        FROM dual
        WHERE NOT EXISTS(
                SELECT *
                FROM tbr_tc_bc_001
                WHERE thuoc_tinh_1 = '005'
            );

        --        INSERT INTO tbr_tc_bc_001 (
--            dien_giai,
--            ma_tk,
--            thuoc_tinh_11, --Tong so 
--            thuoc_tinh_1,
--            thuoc_tinh_2
--        )
--            SELECT
--                'Số dư cuối kỳ:',
--                '0',
--                '0',
--                '006',
--                'B'
--            FROM
--                dual
--            WHERE
--                NOT EXISTS (
--                    SELECT
--                        *
--                    FROM
--                        tbr_tc_bc_001
--                    WHERE
--                        thuoc_tinh_1 = '006 '
--                );

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_32: Bảng đối chiếu số dư tài khoản tiền gửi
    -- Người sửa: HoangV
    -- Ngày sửa: 28/06/2021
    */
    PROCEDURE prc_bang_doi_chieu_tai_khoan_tien_gui(
        p_ma_dvhq VARCHAR2,
        p_dvqhns_id NUMBER,
        p_ngay_tu DATE,
        p_ngay_den DATE
    ) AS
    BEGIN

        --Lay phat sinh tang trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   tkdt_nh_id,
                                   thuoc_tinh_11, --So lieu tai don vi 
                                   thuoc_tinh_1)
        SELECT 'Phát sinh tăng trong kỳ',
               ht.tkdt_nh_id,
               SUM(nvl(ht.so_tien_vnd_no, 0)),
               '003' thuoc_tinh_1
        FROM tbd_tc_ht ht,
             tbd_tc_bt bt
        WHERE ht.bt_id = bt.id
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk LIKE '1121%'
          AND ht.tkdt_nh_id IS NOT NULL
          AND (p_dvqhns_id IS NULL
            OR bt.dvhq_dvqhns_id = p_dvqhns_id)
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'))
        GROUP BY ht.tkdt_nh_id;
        --Lay phat sinh giam trong ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   tkdt_nh_id,
                                   thuoc_tinh_11, --So lieu tai don vi 
                                   thuoc_tinh_1)
        SELECT 'Phát sinh giảm trong kỳ',
               ht.tkdt_nh_id,
               SUM(nvl(ht.so_tien_vnd_co, 0)),
               '004' thuoc_tinh_1
        FROM tbd_tc_ht ht,
             tbd_tc_bt bt
        WHERE ht.bt_id = bt.id
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk LIKE '1121%'
          AND ht.tkdt_nh_id IS NOT NULL
          AND (p_dvqhns_id IS NULL
            OR bt.dvhq_dvqhns_id = p_dvqhns_id)
          AND trunc(ht.ngay_ht, 'DD') BETWEEN nvl(p_ngay_tu, TO_DATE('01/01/1900', 'DD/MM/YYYY')) AND nvl(p_ngay_den,
                                                                                                          TO_DATE(
                                                                                                                  '01/01/1900',
                                                                                                                  'DD/MM/YYYY'))
        GROUP BY ht.tkdt_nh_id;
        --Lay so du cuoi ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   tkdt_nh_id,
                                   thuoc_tinh_11, --So lieu tai don vi 
                                   thuoc_tinh_1)
        SELECT 'Số dư cuối kỳ:'                                                dien_giai,
               ht.tkdt_nh_id                                                   ma_tk,
               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) thuoc_tinh_11,
               '005'                                                           thuoc_tinh_1
        FROM tbd_tc_ht ht,
             tbd_tc_bt bt
        WHERE ht.bt_id = bt.id
          AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
          AND ht.ma_tk LIKE '1121%'
          AND ht.tkdt_nh_id IS NOT NULL
          AND (p_dvqhns_id IS NULL
            OR bt.dvhq_dvqhns_id = p_dvqhns_id)
          AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
        GROUP BY ht.tkdt_nh_id;
        --Lay so du dau ky
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   tkdt_nh_id,
                                   thuoc_tinh_11, --So lieu tai don vi 
                                   thuoc_tinh_1)
        SELECT 'Số dư đầu kỳ:',
               dl.nh_id,
               (
                   SELECT SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) thuoc_tinh_11
                   FROM tbd_tc_ht ht,
                        tbd_tc_bt bt
                   WHERE ht.bt_id = bt.id
                     AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                     AND ht.ma_tk LIKE '1121%'
                     AND ht.tkdt_nh_id = dl.nh_id
                     AND trunc(ht.ngay_ht, 'DD') < nvl(p_ngay_tu, TO_DATE('02/01/1900', 'DD/MM/YYYY'))
               ),
               '002'
        FROM (
                 SELECT DISTINCT tkdt_nh_id AS nh_id
                 FROM tbr_tc_bc_001
             ) dl;
        --Lay so tai khoan 
        INSERT INTO tbr_tc_bc_001 (dien_giai,
                                   tkdt_nh_id,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT DISTINCT 'Tài khoản: ' || kbnh.so_tai_khoan dien_giai,
                        dl.tkdt_nh_id,
                        '001'                              thuoc_tinh_1,
                        'B'                                thuoc_tinh_2
        FROM tbr_tc_bc_001 dl,
             tbd_tc_dvhq_kbnh kbnh
        WHERE dl.tkdt_nh_id = kbnh.id;

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_33 – Báo cáo tình hình tài chính
    -- Người sửa: HoangV
    -- Ngày sửa: 14/07/2021
    */
    PROCEDURE prc_bao_cao_tinh_hinh_tai_chinh(
        p_ma_bao_cao VARCHAR2,
        p_ma_dvhq VARCHAR2,
        p_nam DATE
    ) AS
    BEGIN
        --Lay du lieu dau nam cuoi nam, dau nam tai khoan no, co
        INSERT INTO tbr_tc_bc_002 (ma_bao_cao,
                                   stt,
                                   id_chi_tieu,
                                   ten_chi_tieu,
                                   cap_tong_hop,
                                   ma_so,
                                   so_cuoi_nam,
                                   so_dau_nam,
                                   thuoc_tinh_11)
        SELECT ma_bao_cao,
               stt,
               id,
               ten_chi_tieu,
               cap_tong_hop,
               ma_so,
               SUM(nvl(so_cuoi_nam, 0)) so_cuoi_nam,
               SUM(nvl(so_dau_nam, 0))  so_dau_nam,
               thuoc_tinh_3
        FROM (
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        ct.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))) so_cuoi_nam,
                        0                                                                       so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM tbd_tc_ht ht,
                      tbs_sys_bc_chi_tieu ct,
                      tbs_sys_bc_chi_tieu_cthuc ctct
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ct.ma_bao_cao = p_ma_bao_cao
                   AND ct.id = ctct.chi_tieu_id
                   AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                     SELECT *
                     FROM
                         split(ctct.ma_tk)
                 )
                   AND ctct.thuoc_tinh_1 IN ('N', 'C')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY ct.ma_bao_cao,
                          ct.id,
                          ct.stt,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          ctct.thuoc_tinh_1,
                          ct.thuoc_tinh_3
                 UNION ALL
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        ct.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        0 AS                                                                    so_cuoi_nam,
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0))) so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM tbd_tc_ht ht,
                      tbs_sys_bc_chi_tieu ct,
                      tbs_sys_bc_chi_tieu_cthuc ctct
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ct.ma_bao_cao = p_ma_bao_cao
                   AND ct.id = ctct.chi_tieu_id
                   AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                     SELECT *
                     FROM
                         split(ctct.ma_tk)
                 )
                   AND ctct.thuoc_tinh_1 IN ('N', 'C')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                  - 12) AND
                     add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 0)
                 GROUP BY ct.ma_bao_cao,
                          ct.id,
                          ct.stt,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          ctct.thuoc_tinh_1,
                          ct.thuoc_tinh_3
                 UNION ALL
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        dl.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        decode(dl.thuoc_tinh_1, 'LTN', SUM(nvl(dl.so_du_no, 0)), 'LTC',
                               SUM(nvl(dl.so_du_co, 0))) so_cuoi_nam,
                        0                                so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM (
                          SELECT st.id,
                                 st.dttk,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co,
                                 st.thuoc_tinh_1
                          FROM (
                                   SELECT ct.id,
                                          ht.dttk,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien,
                                          ctct.thuoc_tinh_1
                                   FROM tbd_tc_ht ht,
                                        tbs_sys_bc_chi_tieu ct,
                                        tbs_sys_bc_chi_tieu_cthuc ctct
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND ct.ma_bao_cao = p_ma_bao_cao
                                     AND ct.id = ctct.chi_tieu_id
                                     AND ctct.ma_tk_loai_tru IS NOT NULL
                                     AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                                       SELECT *
                                       FROM
                                           split(ctct.ma_tk)
                                   )
                                     AND substr(ctct.thuoc_tinh_1, 1, 2) = 'LT'
                                     AND ctct.ma_tk_loai_tru IS NOT NULL
                                     AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND
                                       add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                                   GROUP BY ht.dttk,
                                            ct.id,
                                            ctct.thuoc_tinh_1
                               ) st
                      ) dl,
                      tbs_sys_bc_chi_tieu ct
                 WHERE dl.id = ct.id
                 GROUP BY ct.ma_bao_cao,
                          ct.stt,
                          dl.id,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          dl.thuoc_tinh_1,
                          ct.thuoc_tinh_3
                 UNION ALL
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        dl.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        0                                so_cuoi_nam,
                        decode(dl.thuoc_tinh_1, 'LTN', SUM(nvl(dl.so_du_no, 0)), 'LTC',
                               SUM(nvl(dl.so_du_co, 0))) so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM (
                          SELECT st.id,
                                 st.dttk,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co,
                                 st.thuoc_tinh_1
                          FROM (
                                   SELECT ct.id,
                                          ht.dttk,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien,
                                          ctct.thuoc_tinh_1
                                   FROM tbd_tc_ht ht,
                                        tbs_sys_bc_chi_tieu ct,
                                        tbs_sys_bc_chi_tieu_cthuc ctct
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND ct.ma_bao_cao = p_ma_bao_cao
                                     AND ct.id = ctct.chi_tieu_id
                                     AND ctct.ma_tk_loai_tru IS NOT NULL
                                     AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                                       SELECT *
                                       FROM
                                           split(ctct.ma_tk)
                                   )
                                     AND substr(ctct.thuoc_tinh_1, 1, 2) = 'LT'
                                     AND (ctct.ma_tk_loai_tru IS NOT NULL)
                                     AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(
                                           trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                 'YEAR'), - 12) AND add_months(
                                           trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                           0)
                                   GROUP BY ht.dttk,
                                            ct.id,
                                            ctct.thuoc_tinh_1
                               ) st
                      ) dl,
                      tbs_sys_bc_chi_tieu ct
                 WHERE dl.id = ct.id
                 GROUP BY ct.ma_bao_cao,
                          ct.stt,
                          dl.id,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          dl.thuoc_tinh_1,
                          ct.thuoc_tinh_3
                 UNION ALL
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        dl.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        decode(dl.thuoc_tinh_1, 'LTN', SUM(nvl(dl.so_du_no, 0)), 'LTC',
                               SUM(nvl(dl.so_du_co, 0))) so_cuoi_nam,
                        0                                so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM (
                          SELECT st.id,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co,
                                 st.thuoc_tinh_1
                          FROM (
                                   SELECT ct.id,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien,
                                          ctct.thuoc_tinh_1
                                   FROM tbd_tc_ht ht,
                                        tbs_sys_bc_chi_tieu ct,
                                        tbs_sys_bc_chi_tieu_cthuc ctct
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND ct.ma_bao_cao = p_ma_bao_cao
                                     AND ct.id = ctct.chi_tieu_id
                                     AND ctct.ma_tk_loai_tru IS NULL
                                     AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                                       SELECT *
                                       FROM
                                           split(ctct.ma_tk)
                                   )
                                     AND substr(ctct.thuoc_tinh_1, 1, 2) = 'LT'
                                     AND ctct.ma_tk_loai_tru IS NULL
                                     AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND
                                       add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                                   GROUP BY ct.id,
                                            ctct.thuoc_tinh_1
                               ) st
                      ) dl,
                      tbs_sys_bc_chi_tieu ct
                 WHERE dl.id = ct.id
                 GROUP BY ct.ma_bao_cao,
                          ct.stt,
                          dl.id,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          dl.thuoc_tinh_1,
                          ct.thuoc_tinh_3
                 UNION ALL
                 SELECT ct.ma_bao_cao,
                        ct.stt,
                        dl.id,
                        ct.ten_chi_tieu,
                        ct.cap_tong_hop,
                        ct.ma_so,
                        0                                so_cuoi_nam,
                        decode(dl.thuoc_tinh_1, 'LTN', SUM(nvl(dl.so_du_no, 0)), 'LTC',
                               SUM(nvl(dl.so_du_co, 0))) so_dau_nam,
                        ct.thuoc_tinh_3
                 FROM (
                          SELECT st.id,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co,
                                 st.thuoc_tinh_1
                          FROM (
                                   SELECT ct.id,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien,
                                          ctct.thuoc_tinh_1
                                   FROM tbd_tc_ht ht,
                                        tbs_sys_bc_chi_tieu ct,
                                        tbs_sys_bc_chi_tieu_cthuc ctct
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND ct.ma_bao_cao = p_ma_bao_cao
                                     AND ct.id = ctct.chi_tieu_id
                                     AND ctct.ma_tk_loai_tru IS NULL
                                     AND substr(ht.ma_tk, 1, ctct.thuoc_tinh_5) IN (
                                       SELECT *
                                       FROM
                                           split(ctct.ma_tk)
                                   )
                                     AND substr(ctct.thuoc_tinh_1, 1, 2) = 'LT'
                                     AND ctct.ma_tk_loai_tru IS NULL
                                     AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(
                                           trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                 'YEAR'), - 12) AND add_months(
                                           trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 0)
                                   GROUP BY ct.id,
                                            ctct.thuoc_tinh_1
                               ) st
                      ) dl,
                      tbs_sys_bc_chi_tieu ct
                 WHERE dl.id = ct.id
                 GROUP BY ct.ma_bao_cao,
                          ct.stt,
                          dl.id,
                          ct.ten_chi_tieu,
                          ct.cap_tong_hop,
                          ct.ma_so,
                          dl.thuoc_tinh_1,
                          ct.thuoc_tinh_3
             )
        GROUP BY ma_bao_cao,
                 id,
                 stt,
                 ten_chi_tieu,
                 cap_tong_hop,
                 ma_so,
                 thuoc_tinh_3;


        --Tinh tong theo cap
        INSERT INTO tbr_tc_bc_002 (stt,
                                   id_chi_tieu,
                                   ten_chi_tieu,
                                   cap_tong_hop,
                                   ma_so,
                                   so_cuoi_nam,
                                   so_dau_nam,
                                   thuoc_tinh_1,
                                   thuoc_tinh_11)
        SELECT ct.stt,
               ct.id,
               ct.ten_chi_tieu,
               ct.cap_tong_hop,
               ct.ma_so,
               SUM(nvl(dl.so_cuoi_nam, 0)) so_cuoi_nam,
               SUM(nvl(dl.so_dau_nam, 0))  so_dau_nam,
               'tong',
               ct.thuoc_tinh_3
        FROM tbr_tc_bc_002 dl,
             tbs_sys_bc_chi_tieu ct
        WHERE dl.thuoc_tinh_11 = ct.id
          AND dl.cap_tong_hop = '1'
        GROUP BY dl.thuoc_tinh_11,
                 ct.stt,
                 ct.id,
                 ct.ten_chi_tieu,
                 ct.cap_tong_hop,
                 ct.ma_so,
                 ct.thuoc_tinh_3;

        INSERT INTO tbr_tc_bc_002 (stt,
                                   id_chi_tieu,
                                   ten_chi_tieu,
                                   cap_tong_hop,
                                   ma_so,
                                   so_cuoi_nam,
                                   so_dau_nam,
                                   thuoc_tinh_1,
                                   thuoc_tinh_11)
        SELECT ct.stt,
               ct.id,
               ct.ten_chi_tieu,
               ct.cap_tong_hop,
               ct.ma_so,
               SUM(nvl(dl.so_cuoi_nam, 0)) so_cuoi_nam,
               SUM(nvl(dl.so_dau_nam, 0))  so_dau_nam,
               'tong2',
               ct.thuoc_tinh_3
        FROM tbr_tc_bc_002 dl,
             tbs_sys_bc_chi_tieu ct
        WHERE dl.thuoc_tinh_11 = ct.id
          AND dl.cap_tong_hop = '2'
        GROUP BY dl.thuoc_tinh_11,
                 ct.stt,
                 ct.id,
                 ct.ten_chi_tieu,
                 ct.cap_tong_hop,
                 ct.ma_so,
                 ct.thuoc_tinh_3;

        INSERT INTO tbr_tc_bc_002 (stt,
                                   id_chi_tieu,
                                   ten_chi_tieu,
                                   cap_tong_hop,
                                   ma_so,
                                   so_cuoi_nam,
                                   so_dau_nam,
                                   thuoc_tinh_1,
                                   thuoc_tinh_11)
        SELECT ct.stt,
               ct.id,
               ct.ten_chi_tieu,
               ct.cap_tong_hop,
               ct.ma_so,
               SUM(nvl(dl.so_cuoi_nam, 0)) so_cuoi_nam,
               SUM(nvl(dl.so_dau_nam, 0))  so_dau_nam,
               'tong3',
               ct.thuoc_tinh_3
        FROM tbr_tc_bc_002 dl,
             tbs_sys_bc_chi_tieu ct
        WHERE dl.thuoc_tinh_11 = ct.id
          AND dl.cap_tong_hop = '3'
        GROUP BY dl.thuoc_tinh_11,
                 ct.stt,
                 ct.id,
                 ct.ten_chi_tieu,
                 ct.cap_tong_hop,
                 ct.ma_so,
                 ct.thuoc_tinh_3;

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_48 – Báo cáo Bảng cân đối số phát sinh
    -- Người sửa: HoangV
    -- Ngày sửa: 14/07/2021
    */
    PROCEDURE prc_bao_cao_bang_can_doi_so_phat_sinh(
        p_ma_dvhq VARCHAR2,
        p_nam DATE
    ) AS
    BEGIN
        --Lay du lieu tai khoan tru 131x va 331x
        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3)
        SELECT dl.id,
               dl.ma_tk,
               dl.ten,
               dl.cap_tai_khoan,
               dl.tk_cap_tren_id,
               SUM(dl.so_du_dn_no)    so_du_dn_no,
               SUM(dl.so_du_dn_co)    so_du_dn_co,
               SUM(dl.so_tien_vnd_no) so_tien_vnd_no,
               SUM(dl.so_tien_vnd_co) so_tien_vnd_co,
               SUM(dl.so_du_cn_no)    so_du_cn_no,
               SUM(dl.so_du_cn_co)    so_du_cn_co,
               decode(substr(dl.ma_tk, 1, 1), '0', '005', '001'),
               decode(dl.cap_tai_khoan, 3, 'I'),
               decode(substr(dl.ma_tk, 1, 1), '0', '003')
        FROM (
                 --Lay so du dau nam
                 SELECT dldk.id,
                        dldk.ma_tk,
                        dldk.ten,
                        dldk.cap_tai_khoan,
                        dldk.tk_cap_tren_id,
                        decode(dldk.loai_tai_khoan, 1, dldk.so_tien, 3,
                               decode(dldk.so_tien - abs(dldk.so_tien), 0, dldk.so_tien)) so_du_dn_no,
                        decode(dldk.loai_tai_khoan, 2, abs(dldk.so_tien), 3,
                               decode(dldk.so_tien + abs(dldk.so_tien), 0, abs(dldk.
                                   so_tien)))                                             so_du_dn_co,
                        0                                                                 so_tien_vnd_no,
                        0                                                                 so_tien_vnd_co,
                        0                                                                 so_du_cn_no,
                        0                                                                 so_du_cn_co
                 FROM (
                          SELECT dmtk.id,
                                 ht.ma_tk                                                        ma_tk,
                                 dmtk.ten,
                                 dmtk.cap_tai_khoan,
                                 dmtk.tk_cap_tren_id,
                                 dmtk.loai_tai_khoan                                             loai_tai_khoan,
                                 SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                          FROM tbd_tc_ht ht,
                               tbs_tc_dm_tk dmtk
                          WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND substr(ht.ma_tk, 1, 3) NOT IN ('131', 331)
                            AND ht.ma_tk = dmtk.ma
                            AND trunc(ht.ngay_ht, 'DD') <
                                add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                          GROUP BY dmtk.id,
                                   ht.ma_tk,
                                   dmtk.ten,
                                   dmtk.cap_tai_khoan,
                                   dmtk.tk_cap_tren_id,
                                   dmtk.loai_tai_khoan
                      ) dldk
                 UNION ALL
                 --Lay so phat sinh trong nam
                 SELECT dmtk.id,
                        ht.ma_tk                       ma_tk,
                        dmtk.ten,
                        dmtk.cap_tai_khoan,
                        dmtk.tk_cap_tren_id,
                        0                              so_du_dn_no,
                        0                              so_du_dn_co,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) so_tien_vnd_no,
                        SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien_vnd_co,
                        0                              so_du_cn_no,
                        0                              so_du_cn_co
                 FROM tbd_tc_ht ht,
                      tbs_tc_dm_tk dmtk
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND substr(ht.ma_tk, 1, 3) NOT IN ('131', 331)
                   AND ht.ma_tk = dmtk.ma
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY dmtk.id,
                          ht.ma_tk,
                          dmtk.ten,
                          dmtk.cap_tai_khoan,
                          dmtk.tk_cap_tren_id,
                          dmtk.loai_tai_khoan
                 UNION ALL
                 --Lay so du cuoi nam
                 SELECT dlcn.id,
                        dlcn.ma_tk,
                        dlcn.ten,
                        dlcn.cap_tai_khoan,
                        dlcn.tk_cap_tren_id,
                        0                                                                 so_du_dn_no,
                        0                                                                 so_du_dn_co,
                        0                                                                 so_tien_vnd_no,
                        0                                                                 so_tien_vnd_co,
                        decode(dlcn.loai_tai_khoan, 1, dlcn.so_tien, 3,
                               decode(dlcn.so_tien - abs(dlcn.so_tien), 0, dlcn.so_tien)) so_du_cn_no,
                        decode(dlcn.loai_tai_khoan, 2, abs(dlcn.so_tien), 3,
                               decode(dlcn.so_tien + abs(dlcn.so_tien), 0, abs(dlcn.
                                   so_tien)))                                             so_du_cn_co
                 FROM (
                          SELECT dmtk.id,
                                 ht.ma_tk                                                        ma_tk,
                                 dmtk.ten,
                                 dmtk.cap_tai_khoan,
                                 dmtk.tk_cap_tren_id,
                                 dmtk.loai_tai_khoan                                             loai_tai_khoan,
                                 SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                          FROM tbd_tc_ht ht,
                               tbs_tc_dm_tk dmtk
                          WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND substr(ht.ma_tk, 1, 3) NOT IN ('131', 331)
                            AND ht.ma_tk = dmtk.ma
                            AND trunc(ht.ngay_ht, 'DD') <=
                                add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY dmtk.id,
                                   ht.ma_tk,
                                   dmtk.ten,
                                   dmtk.cap_tai_khoan,
                                   dmtk.tk_cap_tren_id,
                                   dmtk.loai_tai_khoan
                      ) dlcn
             ) dl
        GROUP BY dl.id,
                 dl.ma_tk,
                 dl.ten,
                 dl.cap_tai_khoan,
                 dl.tk_cap_tren_id;
        --Lay du lieu cho tai khoan 131x, 331x
        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT dl.id,
               dl.ma_tk,
               dl.ten,
               dl.cap_tai_khoan,
               dl.tk_cap_tren_id,
               SUM(dl.so_du_dn_no)    so_du_dn_no,
               SUM(dl.so_du_dn_co)    so_du_dn_co,
               SUM(dl.so_tien_vnd_no) so_tien_vnd_no,
               SUM(dl.so_tien_vnd_co) so_tien_vnd_co,
               SUM(dl.so_du_cn_no)    so_du_cn_no,
               SUM(dl.so_du_cn_co)    so_du_cn_co,
               '001',
               decode(dl.cap_tai_khoan, 3, 'I')
        FROM (
                 SELECT dmtk.id,
                        dldn.ma_tk,
                        dmtk.ten,
                        dmtk.cap_tai_khoan,
                        dmtk.tk_cap_tren_id,
                        SUM(nvl(dldn.so_du_no, 0)) so_du_dn_no,
                        SUM(nvl(dldn.so_du_co, 0)) so_du_dn_co,
                        0                          so_tien_vnd_no,
                        0                          so_tien_vnd_co,
                        0                          so_du_cn_no,
                        0                          so_du_cn_co
                 FROM (
                          SELECT st.ma_tk,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co
                          FROM (
                                   SELECT ht.ma_tk,
                                          ht.dttk,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                                   FROM tbd_tc_ht ht
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND substr(ht.ma_tk, 1, 3) IN ('131', '331')
                                     AND trunc(ht.ngay_ht, 'DD') <
                                         add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                                   GROUP BY ht.ma_tk,
                                            ht.dttk
                               ) st
                          GROUP BY st.ma_tk,
                                   st.so_tien
                      ) dldn,
                      tbs_tc_dm_tk dmtk
                 WHERE dldn.ma_tk = dmtk.ma
                 GROUP BY dldn.ma_tk,
                          dmtk.id,
                          dmtk.ten,
                          dmtk.cap_tai_khoan,
                          dmtk.tk_cap_tren_id
                 UNION ALL
                 --Lay so phat sinh trong nam
                 SELECT dmtk.id,
                        ht.ma_tk                       ma_tk,
                        dmtk.ten,
                        dmtk.cap_tai_khoan,
                        dmtk.tk_cap_tren_id,
                        0                              so_du_dn_no,
                        0                              so_du_dn_co,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) so_tien_vnd_no,
                        SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien_vnd_co,
                        0                              so_du_cn_no,
                        0                              so_du_cn_co
                 FROM tbd_tc_ht ht,
                      tbs_tc_dm_tk dmtk
                 WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND substr(ht.ma_tk, 1, 3) IN ('131', 331)
                   AND ht.ma_tk = dmtk.ma
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY dmtk.id,
                          ht.ma_tk,
                          dmtk.ten,
                          dmtk.cap_tai_khoan,
                          dmtk.tk_cap_tren_id,
                          dmtk.loai_tai_khoan
                 UNION ALL
                 --Lay so du cuoi nam
                 SELECT dmtk.id,
                        dlcn.ma_tk,
                        dmtk.ten,
                        dmtk.cap_tai_khoan,
                        dmtk.tk_cap_tren_id,
                        0                          so_du_dn_no,
                        0                          so_du_dn_co,
                        0                          so_tien_vnd_no,
                        0                          so_tien_vnd_co,
                        SUM(nvl(dlcn.so_du_no, 0)) so_du_cn_no,
                        SUM(nvl(dlcn.so_du_co, 0)) so_du_cn_co
                 FROM (
                          SELECT st.ma_tk,
                                 decode(st.so_tien - abs(st.so_tien), 0, st.so_tien, 0)      so_du_no,
                                 decode(st.so_tien + abs(st.so_tien), 0, abs(st.so_tien), 0) so_du_co
                          FROM (
                                   SELECT ht.ma_tk,
                                          ht.dttk,
                                          SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) so_tien
                                   FROM tbd_tc_ht ht
                                   WHERE ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                     AND substr(ht.ma_tk, 1, 3) IN ('131', '331')
                                     AND trunc(ht.ngay_ht, 'DD') <=
                                         add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                                   GROUP BY ht.ma_tk,
                                            ht.dttk
                               ) st
                          GROUP BY st.ma_tk,
                                   st.so_tien
                      ) dlcn,
                      tbs_tc_dm_tk dmtk
                 WHERE dlcn.ma_tk = dmtk.ma
                 GROUP BY dlcn.ma_tk,
                          dmtk.id,
                          dmtk.ten,
                          dmtk.cap_tai_khoan,
                          dmtk.tk_cap_tren_id
             ) dl
        GROUP BY dl.id,
                 dl.ma_tk,
                 dl.ten,
                 dl.cap_tai_khoan,
                 dl.tk_cap_tren_id;


        --Tinh tong
        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   thuoc_tinh_2,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12)
        SELECT dmtk.id,
               dmtk.ma,
               dmtk.ten,
               '',
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               decode(substr(dmtk.ma, 1, 1), '0', '005', '001'),
               decode(substr(dmtk.ma, 1, 1), '0', '003'),
               dmtk.cap_tai_khoan,
               dmtk.tk_cap_tren_id
        FROM tbr_tc_bc_001 dl,
             tbs_tc_dm_tk dmtk
        WHERE dl.thuoc_tinh_12 = dmtk.id
          AND dl.thuoc_tinh_11 = '5'
        GROUP BY dmtk.id,
                 dmtk.ma,
                 dmtk.ten,
                 dmtk.cap_tai_khoan,
                 dmtk.tk_cap_tren_id;

        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   thuoc_tinh_2,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12)
        SELECT dmtk.id,
               dmtk.ma,
               dmtk.ten,
               'I',
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               decode(substr(dmtk.ma, 1, 1), '0', '005', '001'),
               decode(substr(dmtk.ma, 1, 1), '0', '003'),
               dmtk.cap_tai_khoan,
               dmtk.tk_cap_tren_id
        FROM tbr_tc_bc_001 dl,
             tbs_tc_dm_tk dmtk
        WHERE dl.thuoc_tinh_12 = dmtk.id
          AND dl.thuoc_tinh_11 = '4'
        GROUP BY dmtk.id,
                 dmtk.ma,
                 dmtk.ten,
                 dmtk.cap_tai_khoan,
                 dmtk.tk_cap_tren_id;

        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12)
        SELECT dmtk.id,
               dmtk.ma,
               dmtk.ten,
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               decode(substr(dmtk.ma, 1, 1), '0', '005', '001'),
               decode(substr(dmtk.ma, 1, 1), '0', '003'),
               dmtk.cap_tai_khoan,
               dmtk.tk_cap_tren_id
        FROM tbr_tc_bc_001 dl,
             tbs_tc_dm_tk dmtk
        WHERE dl.thuoc_tinh_12 = dmtk.id
          AND dl.thuoc_tinh_11 = '3'
        GROUP BY dmtk.id,
                 dmtk.ma,
                 dmtk.ten,
                 dmtk.cap_tai_khoan,
                 dmtk.tk_cap_tren_id;

        INSERT INTO tbr_tc_bc_001 (ma_tk_id,
                                   ma_tk,
                                   ten_tk,
                                   thuoc_tinh_2,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3,
                                   thuoc_tinh_11,
                                   thuoc_tinh_12)
        SELECT dmtk.id,
               dmtk.ma,
               dmtk.ten,
               'B',
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               decode(substr(dmtk.ma, 1, 1), '0', '005', '001'),
               decode(substr(dmtk.ma, 1, 1), '0', '003'),
               dmtk.cap_tai_khoan,
               dmtk.tk_cap_tren_id
        FROM tbr_tc_bc_001 dl,
             tbs_tc_dm_tk dmtk
        WHERE dl.thuoc_tinh_12 = dmtk.id
          AND dl.thuoc_tinh_11 = '2'
        GROUP BY dmtk.id,
                 dmtk.ma,
                 dmtk.ten,
                 dmtk.cap_tai_khoan,
                 dmtk.tk_cap_tren_id;

        INSERT INTO tbr_tc_bc_001 (ma_tk,
                                   thuoc_tinh_1)
        VALUES (' ',
                '003');

        INSERT INTO tbr_tc_bc_001 (ten_tk,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3)
        VALUES ('CÁC TÀI KHOẢN NGOÀI BẢNG',
                '004',
                '003');

        INSERT INTO tbr_tc_bc_001 (ten_tk,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 'Cộng',
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               '002',
               'BM'
        FROM tbr_tc_bc_001 dl
        WHERE substr(dl.ma_tk, 1, 1) <> '0'
          AND thuoc_tinh_11 = 1;

        INSERT INTO tbr_tc_bc_001 (ten_tk,
                                   so_du_dn_no,
                                   so_du_dn_co,
                                   so_tien_vnd_no,
                                   so_tien_vnd_co,
                                   so_du_cn_no,
                                   so_du_cn_co,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3)
        SELECT 'Cộng',
               SUM(nvl(dl.so_du_dn_no, 0))    so_du_dn_no,
               SUM(nvl(dl.so_du_dn_co, 0))    so_du_dn_co,
               SUM(nvl(dl.so_tien_vnd_no, 0)) so_tien_vnd_no,
               SUM(nvl(dl.so_tien_vnd_co, 0)) so_tien_vnd_co,
               SUM(nvl(dl.so_du_cn_no, 0))    so_du_cn_no,
               SUM(nvl(dl.so_du_cn_co, 0))    so_du_cn_co,
               '006',
               'BM',
               '003'
        FROM tbr_tc_bc_001 dl
        WHERE substr(dl.ma_tk, 1, 1) = '0'
          AND thuoc_tinh_11 = 1;

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_30 - Báo cáo Báo cáo tình hình thực hiện dự toán KPTX của các nhiệm vụ được chuyển sang năm sau (Không phải xét chuyển)
    -- Người sửa: HoangV
    -- Ngày sửa: 20/07/2021
    */
    PROCEDURE prc_bao_cao_bang_tinh_hinh_thuc_hien_du_toan_KPTX(
        p_ma_dvhq VARCHAR2,
        p_nam DATE,
        p_ma_kbnh NUMBER
    ) AS
    BEGIN
        --LAY CHI TIEU 1
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   khoan,
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3)
        SELECT nns.ten,
               tk.ma_nguon_ns,
               tk.khoan,
               SUM(nvl(tk.du_an_nam_truoc_chuyen_sang, 0)) thuoc_tinh_12,
               SUM(nvl(tk.du_toan_giao_dau_nam, 0))        thuoc_tinh_13,
               SUM(nvl(tk.du_toan_dieu_chinh, 0))          thuoc_tinh_14,
               SUM(nvl(tk.du_toan_da_su_dung, 0))          thuoc_tinh_15,
               SUM(nvl(tk.so_du_toan_bi_huy, 0))           thuoc_tinh_16,
               SUM(nvl(tk.so_du_tam_ung, 0))               thuoc_tinh_18,
               '002'                                       thuoc_tinh_1,
               '002'                                       thuoc_tinh_3
        FROM (
                 SELECT ht.ma_nguon_ns,
                        ht.khoan,
                        0                                                              du_an_nam_truoc_chuyen_sang,
                        decode(ht.ma_loai_nv, '09', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_giao_dau_nam,
                        decode(ht.ma_loai_nv, '10', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_dieu_chinh,
                        CASE
                            WHEN ht.ma_loai_nv IN ('11', '12', '13', '14', '18',
                                                   '19') THEN
                                SUM(nvl(ht.so_tien_vnd_co, 0))
                            ELSE
                                0
                            END                                                        du_toan_da_su_dung,
                        decode(ht.ma_loai_nv, '20', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) so_du_toan_bi_huy,
                        0                                                              so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.khoan IS NOT NULL
                   AND ht.ma_ctmt IS NULL
                   AND ht.ma_tk LIKE '008%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_loai_nv
                 UNION ALL
                 --Lay du an nam truoc chuyen sang
                 SELECT ht.ma_nguon_ns,
                        ht.khoan,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) du_an_nam_truoc_chuyen_sang,
                        0                                                               du_toan_giao_dau_nam,
                        0                                                               du_toan_dieu_chinh,
                        0                                                               du_toan_da_su_dung,
                        0                                                               so_du_toan_bi_huy,
                        0                                                               so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.ma_ctmt IS NULL
                   AND ht.khoan IS NOT NULL
                   AND ht.ma_tk LIKE '008%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '17', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                  - 12) AND
                     add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 0)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_loai_nv
                 UNION ALL
                 --Lay thanh toan tam ung
                 SELECT dl.ma_nguon_ns,
                        dl.khoan,
                        0                                                        du_an_nam_truoc_chuyen_sang,
                        0                                                        du_toan_giao_dau_nam,
                        0                                                        du_toan_dieu_chinh,
                        0                                                        du_toan_da_su_dung,
                        0                                                        so_du_toan_bi_huy,
                        SUM(nvl(dl.phat_sinh_co, 0)) - SUM(nvl(dl.tong_tttu, 0)) so_du_tam_ung
                 FROM (
                          SELECT ht.ma_nguon_ns                 ma_nguon_ns,
                                 ht.khoan,
                                 SUM(nvl(ht.so_tien_vnd_co, 0)) phat_sinh_co,
                                 0                              tong_tttu
                          FROM tbd_tc_ht ht,
                               tbs_dm_nns nns,
                               tbd_tc_dvhq_kbnh kbnh
                          WHERE ht.ma_nguon_ns = nns.ma
                            AND ht.tkdt_nh_id = kbnh.id
                            AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND ht.khoan IS NOT NULL
                            AND ht.ma_ctmt IS NULL
                            AND ht.ma_tk LIKE '008%'
                            AND ht.ma_loai_nv IN ('11', '12', '18')
                            AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                  trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY ht.ma_nguon_ns,
                                   ht.khoan,
                                   ht.ma_nguon_kp
                          UNION ALL
                          SELECT tttuct.ma_nguon_ns             AS ma_nguon_ns,
                                 tttuct.khoan                   AS khoan,
                                 0                                 phat_sinh_co,
                                 SUM(nvl(tttuct.so_tien_tt, 0)) AS tong_tttu
                          FROM tbd_tc_tttu_ct tttuct,
                               tbd_tc_tttu tttu,
                               tbd_tc_dvhq_kbnh kbnh
                          WHERE tttu.id = tttuct.tttu_id
                            AND tttu.dvhq_kbnh_id = kbnh.id
                            AND tttu.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND tttu.ma_ctmt IS NULL
                            AND tttuct.khoan IS NOT NULL
                            AND tttuct.tk_tam_ung LIKE '008%'
                            AND tttuct.ngay_ht BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                      trunc(
                                              nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY tttuct.ma_nguon_ns,
                                   tttuct.khoan
                      ) dl
                 GROUP BY dl.ma_nguon_ns,
                          dl.khoan
             ) tk,
             tbs_dm_nns nns
        WHERE tk.ma_nguon_ns = nns.ma
        GROUP BY nns.ten,
                 tk.ma_nguon_ns,
                 tk.khoan;

        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam 
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3)
        SELECT dl.thuoc_tinh_5,
               dl.ma_nguon_ns,
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '002',
               'BI',
               '001'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '002'
        GROUP BY dl.thuoc_tinh_5,
                 dl.ma_nguon_ns;

        INSERT INTO tbr_tc_bc_001 (stt,
                                   thuoc_tinh_5,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 1,
               'Chi thường xuyên',
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '001',
               'B'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '002'
          AND dl.thuoc_tinh_3 = '001';


        --CHI TIEU 2          
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   khoan,
                                   thuoc_tinh_10, --ma_ctmt
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_18, --so_du_tam_ung
                                   thuoc_tinh_1,
                                   thuoc_tinh_3)
        SELECT nns.ten,
               tk.ma_nguon_ns,
               tk.khoan,
               tk.ma_ctmt,
               SUM(nvl(tk.du_an_nam_truoc_chuyen_sang, 0)) thuoc_tinh_12,
               SUM(nvl(tk.du_toan_giao_dau_nam, 0))        thuoc_tinh_13,
               SUM(nvl(tk.du_toan_dieu_chinh, 0))          thuoc_tinh_14,
               SUM(nvl(tk.du_toan_da_su_dung, 0))          thuoc_tinh_15,
               SUM(nvl(tk.so_du_toan_bi_huy, 0))           thuoc_tinh_16,
               SUM(nvl(tk.so_du_tam_ung, 0))               thuoc_tinh_18,
               '004'                                       thuoc_tinh_1,
               '002'                                       thuoc_tinh_3
        FROM (
                 SELECT ht.ma_ctmt,
                        ht.ma_nguon_ns,
                        ht.khoan,
                        0                                                              du_an_nam_truoc_chuyen_sang,
                        decode(ht.ma_loai_nv, '09', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_giao_dau_nam,
                        decode(ht.ma_loai_nv, '10', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_dieu_chinh,
                        CASE
                            WHEN ht.ma_loai_nv IN ('11', '12', '13', '14', '18',
                                                   '19') THEN
                                SUM(nvl(ht.so_tien_vnd_co, 0))
                            ELSE
                                0
                            END                                                        du_toan_da_su_dung,
                        decode(ht.ma_loai_nv, '20', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) so_du_toan_bi_huy,
                        0                                                              so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.khoan IS NOT NULL
                   AND ht.ma_ctmt IS NOT NULL
                   AND ht.ma_tk LIKE '008%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_ctmt,
                          ht.ma_loai_nv
                 UNION ALL
                 --Lay du an nam truoc chuyen sang
                 SELECT ht.ma_ctmt,
                        ht.ma_nguon_ns,
                        ht.khoan,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) du_an_nam_truoc_chuyen_sang,
                        0                                                               du_toan_giao_dau_nam,
                        0                                                               du_toan_dieu_chinh,
                        0                                                               du_toan_da_su_dung,
                        0                                                               so_du_toan_bi_huy,
                        0                                                               so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.khoan IS NOT NULL
                   AND ht.ma_ctmt IS NOT NULL
                   AND ht.ma_tk LIKE '008%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '17', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                  - 12) AND
                     add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 0)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_ctmt,
                          ht.ma_loai_nv
                 UNION ALL
                 --Lay thanh toan tam ung
                 SELECT dl.ma_ctmt,
                        dl.ma_nguon_ns,
                        dl.khoan,
                        0                                                        du_an_nam_truoc_chuyen_sang,
                        0                                                        du_toan_giao_dau_nam,
                        0                                                        du_toan_dieu_chinh,
                        0                                                        du_toan_da_su_dung,
                        0                                                        so_du_toan_bi_huy,
                        SUM(nvl(dl.phat_sinh_co, 0)) - SUM(nvl(dl.tong_tttu, 0)) so_du_tam_ung
                 FROM (
                          SELECT ht.ma_ctmt,
                                 ht.ma_nguon_ns                 ma_nguon_ns,
                                 ht.khoan,
                                 SUM(nvl(ht.so_tien_vnd_co, 0)) phat_sinh_co,
                                 0                              tong_tttu
                          FROM tbd_tc_ht ht,
                               tbs_dm_nns nns,
                               tbd_tc_dvhq_kbnh kbnh
                          WHERE ht.ma_nguon_ns = nns.ma
                            AND ht.tkdt_nh_id = kbnh.id
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND ht.khoan IS NOT NULL
                            AND ht.ma_ctmt IS NOT NULL
                            AND ht.ma_tk LIKE '008%'
                            AND ht.ma_loai_nv IN ('11', '12', '18')
                            AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                  trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY ht.ma_nguon_ns,
                                   ht.khoan,
                                   ht.ma_ctmt,
                                   ht.ma_nguon_kp
                          UNION ALL
                          SELECT bt.ma_ctmt,
                                 tttuct.ma_nguon_ns             AS ma_nguon_ns,
                                 tttuct.khoan                   AS khoan,
                                 0                                 phat_sinh_co,
                                 SUM(nvl(tttuct.so_tien_tt, 0)) AS tong_tttu
                          FROM tbd_tc_tttu_ct tttuct,
                               tbd_tc_tttu tttu,
                               tbd_tc_dvhq_kbnh kbnh,
                               TBD_TC_BT bt
                          WHERE tttu.id = tttuct.tttu_id
                            AND tttuct.bt_id = bt.id
                            AND tttu.dvhq_kbnh_id = kbnh.id
                            AND tttu.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND tttu.ma_ctmt IS NOT NULL
                            AND tttuct.khoan IS NOT NULL
                            AND tttuct.tk_tam_ung LIKE '008%'
                            AND tttuct.ngay_ht BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                      trunc(
                                              nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY tttuct.ma_nguon_ns,
                                   tttuct.khoan,
                                   bt.ma_ctmt
                      ) dl
                 GROUP BY dl.ma_nguon_ns,
                          dl.ma_ctmt,
                          dl.khoan
             ) tk,
             tbs_dm_nns nns
        WHERE tk.ma_nguon_ns = nns.ma
        GROUP BY nns.ten,
                 tk.ma_nguon_ns,
                 tk.ma_ctmt,
                 tk.khoan;


        --Tinh tong chi tieu 2  nns  
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   thuoc_tinh_10,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3)
        SELECT dl.thuoc_tinh_5,
               dl.ma_nguon_ns,
               dl.thuoc_tinh_10,
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '004',
               'BI',
               '001'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '004'
        GROUP BY dl.thuoc_tinh_5,
                 dl.ma_nguon_ns,
                 dl.thuoc_tinh_10;

        --Tinh tong chi tieu 2 ctmt   
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   thuoc_tinh_10,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3)
        SELECT dl.thuoc_tinh_10 || ' - ' || bt.ten_ctmt,
               '0',
               thuoc_tinh_10,
               SUM(nvl(dl.thuoc_tinh_11, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_17, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '004',
               'B',
               '000'
        FROM tbr_tc_bc_001 dl,
             (SELECT DISTINCT bt.ma_ctmt, bt.ten_ctmt FROM TBD_TC_BT bt) bt
        WHERE dl.thuoc_tinh_10 = bt.ma_ctmt
          AND dl.thuoc_tinh_1 = '004'
          AND dl.thuoc_tinh_3 = '001'
        GROUP BY dl.thuoc_tinh_10 || ' - ' || bt.ten_ctmt, thuoc_tinh_10;
        --Them ten chi tieu 2   
        INSERT INTO tbr_tc_bc_001 (stt,
                                   thuoc_tinh_5,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 2,
               'Kinh phí chương trình MTQG và Chương trình mục tiêu (chi tết từng chương trình)',
               '003',
               'B'
        from dual;

        --CHI TIEU 3             
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   khoan,
                                   thuoc_tinh_19,--loai
                                   thuoc_tinh_20,--thuoc_dact
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_3,
                                   thuoc_tinh_4)
        SELECT nns.ten,
               tk.ma_nguon_ns,
               tk.khoan,
               tk.loai,
               tk.thuoc_dact,
               SUM(nvl(tk.du_an_nam_truoc_chuyen_sang, 0)) thuoc_tinh_12,
               SUM(nvl(tk.du_toan_giao_dau_nam, 0))        thuoc_tinh_13,
               SUM(nvl(tk.du_toan_dieu_chinh, 0))          thuoc_tinh_14,
               SUM(nvl(tk.du_toan_da_su_dung, 0))          thuoc_tinh_15,
               SUM(nvl(tk.so_du_toan_bi_huy, 0))           thuoc_tinh_16,
               SUM(nvl(tk.so_du_tam_ung, 0))               thuoc_tinh_18,
               '006'                                       thuoc_tinh_1,
               '003'                                       thuoc_tinh_3,
               '003'
        FROM (
                 SELECT ht.ma_nguon_ns,
                        ht.khoan,
                        hddact.loai,
                        hddact.thuoc_dact,
                        0                                                              du_an_nam_truoc_chuyen_sang,
                        decode(ht.ma_loai_nv, '09', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_giao_dau_nam,
                        decode(ht.ma_loai_nv, '10', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) du_toan_dieu_chinh,
                        CASE
                            WHEN ht.ma_loai_nv IN ('11', '12', '13', '14', '18',
                                                   '19') THEN
                                SUM(nvl(ht.so_tien_vnd_co, 0))
                            ELSE
                                0
                            END                                                        du_toan_da_su_dung,
                        decode(ht.ma_loai_nv, '20', SUM(nvl(ht.so_tien_vnd_no, 0)), 0) so_du_toan_bi_huy,
                        0                                                              so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh,
                      tbd_tc_hddact hddact,
                      tbs_tc_dm_hddact dmhddact
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.hddact_id = hddact.id
                   AND hddact.loai = dmhddact.id
                   AND dmhddact.ma IN ('02010000', '02020000')
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ht.khoan IS NOT NULL
                   AND ht.chuong = nvl('1', '00')
                   AND ht.ma_tk LIKE '009%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                             trunc(
                                     nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_loai_nv,
                          hddact.loai,
                          hddact.thuoc_dact
                 UNION ALL
                 --Lay du an nam truoc chuyen sang
                 SELECT ht.ma_nguon_ns,
                        ht.khoan,
                        hddact.loai,
                        hddact.thuoc_dact,
                        SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)) du_an_nam_truoc_chuyen_sang,
                        0                                                               du_toan_giao_dau_nam,
                        0                                                               du_toan_dieu_chinh,
                        0                                                               du_toan_da_su_dung,
                        0                                                               so_du_toan_bi_huy,
                        0                                                               so_du_tam_ung
                 FROM tbd_tc_ht ht,
                      tbs_dm_nns nns,
                      tbd_tc_dvhq_kbnh kbnh,
                      tbd_tc_hddact hddact,
                      tbs_tc_dm_hddact dmhddact
                 WHERE ht.ma_nguon_ns = nns.ma
                   AND ht.tkdt_nh_id = kbnh.id
                   AND (p_ma_kbnh IS NULL
                     OR kbnh.kbnh_id = p_ma_kbnh)
                   AND ht.hddact_id = hddact.id
                   AND hddact.loai = dmhddact.id
                   AND dmhddact.ma IN ('02010000', '02020000')
                   AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                   AND ht.khoan IS NOT NULL
                   AND ht.chuong = nvl('1', '00')
                   AND ht.ma_tk LIKE '009%'
                   AND ht.ma_loai_nv IN ('09', '10', '11', '12', '13',
                                         '14', '17', '18', '19', '20')
                   AND trunc(ht.ngay_ht, 'DD') BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                  - 12) AND
                     add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 0)
                 GROUP BY ht.ma_nguon_ns,
                          ht.khoan,
                          ht.ma_loai_nv,
                          hddact.loai,
                          hddact.thuoc_dact
                 UNION ALL
                 --Lay thanh toan tam ung
                 SELECT dl.ma_nguon_ns,
                        dl.khoan,
                        dl.loai,
                        dl.thuoc_dact,
                        0                                                        du_an_nam_truoc_chuyen_sang,
                        0                                                        du_toan_giao_dau_nam,
                        0                                                        du_toan_dieu_chinh,
                        0                                                        du_toan_da_su_dung,
                        0                                                        so_du_toan_bi_huy,
                        SUM(nvl(dl.phat_sinh_co, 0)) - SUM(nvl(dl.tong_tttu, 0)) so_du_tam_ung
                 FROM (
                          SELECT ht.ma_nguon_ns                 ma_nguon_ns,
                                 ht.khoan,
                                 hddact.loai,
                                 hddact.thuoc_dact,
                                 SUM(nvl(ht.so_tien_vnd_co, 0)) phat_sinh_co,
                                 0                              tong_tttu
                          FROM tbd_tc_ht ht,
                               tbs_dm_nns nns,
                               tbd_tc_dvhq_kbnh kbnh,
                               tbd_tc_hddact hddact,
                               tbs_tc_dm_hddact dmhddact
                          WHERE ht.ma_nguon_ns = nns.ma
                            AND ht.tkdt_nh_id = kbnh.id
                            AND ht.hddact_id = hddact.id
                            AND hddact.loai = dmhddact.id
                            AND dmhddact.ma IN ('02010000', '02020000')
                            AND ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND ht.khoan IS NOT NULL
                            AND ht.chuong = nvl('1', '00')
                            AND ht.ma_tk LIKE '009%'
                            AND ht.ma_loai_nv IN ('11', '12', '18')
                            AND trunc(ht.ngay_ht, 'DD') BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                  trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY ht.ma_nguon_ns,
                                   ht.khoan,
                                   ht.ma_nguon_kp,
                                   hddact.loai,
                                   hddact.thuoc_dact
                          UNION ALL
                          SELECT tttuct.ma_nguon_ns             AS ma_nguon_ns,
                                 tttuct.khoan                   AS khoan,
                                 hddact.loai,
                                 hddact.thuoc_dact,
                                 0                                 phat_sinh_co,
                                 SUM(nvl(tttuct.so_tien_tt, 0)) AS tong_tttu
                          FROM tbd_tc_tttu_ct tttuct,
                               tbd_tc_tttu tttu,
                               tbd_tc_hddact hddact,
                               tbs_tc_dm_hddact dmhddact,
                               tbd_tc_dvhq_kbnh kbnh
                          WHERE tttu.id = tttuct.tttu_id
                            AND tttu.dvhq_kbnh_id = kbnh.id
                            AND (p_ma_kbnh IS NULL
                              OR kbnh.kbnh_id = p_ma_kbnh)
                            AND tttu.hddact_id = hddact.id
                            AND hddact.loai = dmhddact.id
                            AND dmhddact.ma IN ('02010000', '02020000')
                            AND tttu.ma_dvhq = nvl(p_ma_dvhq, '00')
                            AND tttuct.khoan IS NOT NULL
                            AND tttuct.tk_tam_ung LIKE '009%'
                            AND tttuct.ngay_ht BETWEEN trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') AND add_months(
                                      trunc(
                                              nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                          GROUP BY tttuct.ma_nguon_ns,
                                   tttuct.khoan,
                                   hddact.loai,
                                   hddact.thuoc_dact
                      ) dl
                 GROUP BY dl.ma_nguon_ns,
                          dl.khoan,
                          dl.loai,
                          dl.thuoc_dact
             ) tk,
             tbs_dm_nns nns
        WHERE tk.ma_nguon_ns = nns.ma
        GROUP BY nns.ten,
                 tk.ma_nguon_ns,
                 tk.khoan,
                 tk.loai,
                 tk.thuoc_dact;
        --Tinh tong chi tieu 3    
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   ma_nguon_ns,
                                   thuoc_tinh_19,--loai
                                   thuoc_tinh_20,--thuoc_dact
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3,
                                   thuoc_tinh_4)
        SELECT dl.thuoc_tinh_5,
               dl.ma_nguon_ns,
               dl.thuoc_tinh_19,
               dl.thuoc_tinh_20,
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '006',
               'BI',
               '002',
               '002'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '006'
          AND dl.thuoc_tinh_3 = '003'
        GROUP BY dl.thuoc_tinh_5,
                 dl.ma_nguon_ns,
                 dl.thuoc_tinh_19,
                 dl.thuoc_tinh_20;
        --Tinh tong chi tieu 3   
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_5,
                                   thuoc_tinh_20,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2,
                                   thuoc_tinh_3,
                                   thuoc_tinh_4)
        SELECT hddact.so_hddact,
               dl.thuoc_tinh_20,
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '006',
               'B',
               '001',
               '001'
        FROM tbr_tc_bc_001 dl,
             tbd_tc_hddact hddact
        WHERE dl.thuoc_tinh_20 = hddact.id
          AND dl.thuoc_tinh_1 = '006'
          AND dl.thuoc_tinh_3 = '002'
        GROUP BY hddact.so_hddact,
                 dl.thuoc_tinh_20;
        --Tinh tong chi tieu 3   
        INSERT INTO tbr_tc_bc_001 (stt,
                                   thuoc_tinh_5,
                                   thuoc_tinh_11, --tong_so
                                   thuoc_tinh_12, --du_an_nam_truoc_chuyen_sang
                                   thuoc_tinh_13, --du_toan_giao_dau_nam
                                   thuoc_tinh_14, --du_toan_dieu_chinh
                                   thuoc_tinh_15, --du_toan_da_su_dung
                                   thuoc_tinh_16, --so_du_toan_bi_huy
                                   thuoc_tinh_17, --so_du_du_toan
                                   thuoc_tinh_18, --so_du_tam_ung,
                                   thuoc_tinh_1,
                                   thuoc_tinh_2)
        SELECT 3,
               'Chi đầu tư phát triển',
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)),
               SUM(nvl(dl.thuoc_tinh_13, 0)),
               SUM(nvl(dl.thuoc_tinh_14, 0)),
               SUM(nvl(dl.thuoc_tinh_15, 0)),
               SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_12, 0)) + SUM(nvl(dl.thuoc_tinh_13, 0)) + SUM(nvl(dl.thuoc_tinh_14, 0)) -
               SUM(nvl(dl.thuoc_tinh_15,
                       0)) - SUM(nvl(dl.thuoc_tinh_16, 0)),
               SUM(nvl(dl.thuoc_tinh_18, 0)),
               '005',
               'B'
        FROM tbr_tc_bc_001 dl
        WHERE dl.thuoc_tinh_1 = '006'
          AND dl.thuoc_tinh_3 = '001';

    END;


    /*
    -- Mã/Tên chức năng: TCKT_BC_71 – Biên bản đối chiếu công nợ
    -- Người sửa: HoangV
    -- Ngày sửa: 22/08/2021
    */
    PROCEDURE prc_bao_cao_bang_tinh_hinh_thuc_hien_du_toan(
        p_ma_dvhq VARCHAR2,
        p_ngay_den DATE,
        p_doi_tuong NUMBER
    ) AS
    BEGIN
        INSERT INTO tbr_tc_bc_001 (thuoc_tinh_11,
                                   thuoc_tinh_3,
                                   thuoc_tinh_4,
                                   thuoc_tinh_12,
                                   thuoc_tinh_13,
                                   thuoc_tinh_14,
                                   thuoc_tinh_15)
        SELECT *
        FROM (SELECT dl.id,
                     dl.so_hddact,
                     dl.noi_dung,
                     dl.gia_tri_hop_dong,
                     dl.gia_tri_nghiem_thu,
                     nvl(dl.so_da_thanh_toan, 0),
                     CASE
                         WHEN dl.gia_tri_nghiem_thu > 0 THEN
                             dl.gia_tri_nghiem_thu - nvl(dl.so_da_thanh_toan, 0)
                         WHEN dl.gia_tri_nghiem_thu = 0 THEN
                             dl.gia_tri_hop_dong - nvl(dl.so_da_thanh_toan, 0)
                         END so_con_phai_thanh_toan
              FROM (
                       SELECT hddact.id,
                              hddact.so_hddact,
                              hddact.noi_dung,
                              hddact.gia_tri + nvl(hddact.dieu_chinh_gia_tri, 0) gia_tri_hop_dong,
                              hddact.gia_tri_nghiem_thu,
                              nvl(hddact.so_thanh_toan_luy_ke, 0) + (
                                  SELECT nvl(SUM(ht.so_tien_vnd_no), 0)
                                  FROM tbd_tc_ht ht
                                  WHERE ht.ma_tk LIKE '331%'
                                    AND ht.hddact_id = hddact.id
                                    AND trunc(ht.ngay_ht, 'DD') <= nvl(p_ngay_den, TO_DATE('01/01/1900', 'DD/MM/YYYY'))
                              )                                                  so_da_thanh_toan
                       FROM tbd_tc_hddact hddact
                       WHERE ma_dvhq = nvl(p_ma_dvhq, '00')
                         AND don_vi_thuc_hien = nvl(p_doi_tuong, '00')
                         AND hddact.trang_thai = 1
                   ) dl) loc
        WHERE loc.so_con_phai_thanh_toan != 0;

    END;

END pkg_bc_tckt_hoang;
/


