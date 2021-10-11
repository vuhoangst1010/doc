--------------------------------------------------------
--  File created - Tuesday-September-21-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PKG_BC_DONG_TCKT_HOANG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "KTNB_TEST"."PKG_BC_DONG_TCKT_HOANG" AS
    /*
    -- Mã/Tên ch?c n?ng: TCKT_BC_33 – Báo cáo tình hình tài chính
    -- Ng??i s?a: HoangV
    -- Ngày s?a: 07/07/2021
    */ PROCEDURE prc_bao_cao_tinh_hinh_tai_chinh (
        p_ma_dvhq  VARCHAR2,
        p_nam      DATE
    ) AS
        v_tong_cap           NUMBER;
        v_kiem_tra_khac_cap  NUMBER;
    BEGIN
    --Tinh chi tieu theo tai khoan
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_11,
            so_cuoi_nam,
            so_dau_nam
        )
            SELECT
                ctct.chi_tieu_id,
                ctct.id    AS id,
                (
                    SELECT
                        SUM(so_tien)
                    FROM
                        (
                            SELECT
                                ht.dttk,
                                ht.ma_tk,
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0) AS so_tien
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                            GROUP BY
                                ctct.thuoc_tinh_1,
                                ht.dttk,
                                ht.ma_tk
                        )
                    WHERE
                        so_tien > 0
                )          AS so_cuoi_nam,
                (
                    SELECT
                        SUM(so_tien)
                    FROM
                        (
                            SELECT
                                ht.dttk,
                                ht.ma_tk,
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0) AS so_tien
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                            GROUP BY
                                ctct.thuoc_tinh_1,
                                ht.dttk,
                                ht.ma_tk
                        )
                    WHERE
                        so_tien > 0
                )          AS so_dau_nam
            FROM
                tbs_sys_bc_chi_tieu_cthuc ctct
            WHERE
                    ctct.ma_bao_cao = 'TCKT_BC_33'
                AND ctct.thuoc_tinh_15 = 'dt'
                OR ctct.thuoc_tinh_15 = 'tk'
                AND ctct.thuoc_tinh_9 IS NOT NULL;

    --tinh chi tieu khong co cong thuc con
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_11,
            so_cuoi_nam,
            so_dau_nam
        )
            SELECT
                ctct.chi_tieu_id    AS ctid,
                ctct.id             ctctid,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                        tbd_tc_ht ht
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)              AS so_cuoi_nam,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                        tbd_tc_ht ht
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)              AS so_dau_nam
            FROM
                tbs_sys_bc_chi_tieu_cthuc ctct
            WHERE
                    ctct.ma_bao_cao = 'TCKT_BC_33'
                AND ctct.thuoc_tinh_9 IS NOT NULL
                AND ctct.thuoc_tinh_15 IS NULL;
     -- tinh tong cho bang cong thuc
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            so_cuoi_nam,
            so_dau_nam
        )
            SELECT
                ct.id    AS id,
                SUM((
                    SELECT
                        SUM(decode(phep_toan, '+', nvl((
                            SELECT
                                dl1.so_cuoi_nam
                            FROM
                                tbr_tc_bc_002              dl1,
                                tbs_sys_bc_chi_tieu_cthuc  ctct1
                            WHERE
                                    dl1.thuoc_tinh_11 = ctct1.id
                                AND dl1.thuoc_tinh_11 = id_ctct
                        ),
                                                       0),
                                   '-',
                                   nvl((
                                                        SELECT
                                                            dl1.so_cuoi_nam
                                                        FROM
                                                            tbr_tc_bc_002              dl1,
                                                            tbs_sys_bc_chi_tieu_cthuc  ctct1
                                                        WHERE
                                                                dl1.thuoc_tinh_11 = ctct1.id
                                                            AND dl1.thuoc_tinh_11 = id_ctct
                                                    ) * - 1,
                                       0)))
                    FROM
                        (
                            SELECT
                                substr(t.column_value, 2)            AS id_ctct,
                                substr(t.column_value, 1, 1)         AS phep_toan
                            FROM
                                split(ctct.thuoc_tinh_3, ',') t
                        )
                ))       AS so_tien_cuoi_nam,
                SUM((
                    SELECT
                        SUM(decode(phep_toan, '+', nvl((
                            SELECT
                                dl1.so_dau_nam
                            FROM
                                tbr_tc_bc_002              dl1,
                                tbs_sys_bc_chi_tieu_cthuc  ctct1
                            WHERE
                                    dl1.thuoc_tinh_11 = ctct1.id
                                AND dl1.thuoc_tinh_11 = id_ctct
                        ),
                                                       0),
                                   '-',
                                   nvl((
                                                        SELECT
                                                            dl1.so_dau_nam
                                                        FROM
                                                            tbr_tc_bc_002              dl1,
                                                            tbs_sys_bc_chi_tieu_cthuc  ctct1
                                                        WHERE
                                                                dl1.thuoc_tinh_11 = ctct1.id
                                                            AND dl1.thuoc_tinh_11 = id_ctct
                                                    ) * - 1,
                                       0)))
                    FROM
                        (
                            SELECT
                                substr(t.column_value, 2)            AS id_ctct,
                                substr(t.column_value, 1, 1)         AS phep_toan
                            FROM
                                split(ctct.thuoc_tinh_3, ',') t
                        )
                ))       AS so_tien_dau_nam
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ctct.ma_bao_cao = 'TCKT_BC_33'
                AND ctct.thuoc_tinh_1 IS NULL
                AND ctct.thuoc_tinh_3 IS NOT NULL
            GROUP BY
                ct.id;

    --tinh tong cho bang chi tieu 
        SELECT
            MAX(ct.cap_tong_hop)
        INTO v_tong_cap
        FROM
            tbs_sys_bc_chi_tieu ct
        WHERE
            ct.ma_bao_cao = 'TCKT_BC_33';

        FOR v_index IN REVERSE 1..v_tong_cap LOOP             
                    -- tinh khac cap
            INSERT INTO tbr_tc_bc_002 (
                id_chi_tieu,
                cap_tong_hop,
                so_cuoi_nam,
                so_dau_nam
            )
                SELECT
                    ct.id,
                    ct.cap_tong_hop,
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.so_cuoi_nam, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.so_cuoi_nam, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0)),
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.so_dau_nam, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.so_dau_nam, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0))
                FROM
                    tbs_sys_bc_chi_tieu ct
                WHERE
                        ct.cap_tong_hop = v_index
                    AND ct.thuoc_tinh_2 IS NOT NULL
                    AND ct.ma_bao_cao = 'TCKT_BC_33'
                GROUP BY
                    ct.id,
                    ct.cap_tong_hop;

        END LOOP;

    END;
   

    /*
  -- Mã/Tên ch?c n?ng: TCKT_BC_52 –Báo cáo t?ng h?p tình hình thu chi các qu? và các ngu?n trong thanh toán
  -- Ng??i s?a: HoangV
  -- Ngày s?a: 04/08/2021
  */
    PROCEDURE prc_bao_cao_tong_hop_tinh_hinh_thu_chi (
        p_ma_dvhq  VARCHAR2,
        p_nam      DATE
    ) AS
        v_tong_cap           NUMBER;
        v_kiem_tra_khac_cap  NUMBER;
    BEGIN
        --Tinh chi tieu co cong thuc con
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            cap_tong_hop,
            thuoc_tinh_20
        )
            SELECT
                ct.id              AS id,
                ct.cap_tong_hop    AS cap_tong_hop,
                nvl(SUM((
                    SELECT
                        SUM(decode(phep_toan, '+', nvl((
                            SELECT
                                decode(ctct1.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht                  ht
                                LEFT JOIN tbs_dm_mtm                 mtm ON ht.mtm_id = mtm.id
                                LEFT JOIN tbs_dm_dt                  dt ON ht.dttk = dt.id,
                                tbs_sys_bc_chi_tieu_cthuc  ctct1
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ctct1.id = id_ctct
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct1.thuoc_tinh_9)))
                                AND((ctct1.thuoc_tinh_10 IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                     ctct1.thuoc_tinh_10))
                                    OR(ctct1.thuoc_tinh_10 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_11 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk,
                                                         ctct1.thuoc_tinh_11))
                                    OR(ctct1.thuoc_tinh_11 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_12 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                         ctct1.thuoc_tinh_12))
                                    OR(ctct1.thuoc_tinh_12 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_13 IS NOT NULL
                                     AND ht.dttk IS NOT NULL
                                     AND lower(dt.ma) = '00zz')
                                    OR(ctct1.thuoc_tinh_13 IS NULL
                                       AND REGEXP_LIKE(nvl(to_char(ht.dttk), 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_16 IS NOT NULL
                                     AND ht.mtm_id IS NOT NULL
                                     AND mtm.ma = ctct1.thuoc_tinh_16)
                                    OR(ctct1.thuoc_tinh_16 IS NULL
                                       AND REGEXP_LIKE(nvl(to_char(ht.mtm_id), 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_4 IS NOT NULL
                                     AND ht.mtm_id IS NOT NULL
                                     AND  mtm.ma <> ctct1.thuoc_tinh_4)
                                    OR(ctct1.thuoc_tinh_4 IS NULL
                                       AND REGEXP_LIKE(nvl(to_char(ht.mtm_id), 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_25 IS NULL
                                     AND REGEXP_LIKE(nvl(ht.ma_loai_nv, 'null'),
                                                     '\w*|null'))
                                    OR(substr(ctct1.thuoc_tinh_25, 1, 3) = 'NOT'
                                       AND ht.ma_loai_nv NOT IN(
                                    SELECT
                                        *
                                    FROM
                                        split(substr(ctct1.thuoc_tinh_25, 5), ',')
                                ))
                                    OR(ctct1.thuoc_tinh_25 IS NOT NULL
                                       AND ht.ma_loai_nv IN(
                                    SELECT
                                        *
                                    FROM
                                        split(ctct1.thuoc_tinh_25, ',')
                                )))
                                AND((ctct1.thuoc_tinh_20 = 'TN'
                                     AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                             'YEAR'),
                                                                       0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                               'YEAR') - 1,
                                                                                         12))
                                    OR(ctct1.thuoc_tinh_20 = '<DN'
                                       AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                   0))
                                    OR(ctct1.thuoc_tinh_20 = '<CN'
                                       AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                                                    12)))
                                AND((ctct1.thuoc_tinh_26 IS NULL
                                     AND REGEXP_LIKE(nvl(ht.ma_loai_kp, 'null'),
                                                     '\w*|null'))
                                    OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                       AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                            GROUP BY
                                ctct1.thuoc_tinh_1
                        ),
                                                       0),
                                   '-',
                                   nvl((
                                                        SELECT
                                                            decode(ctct1.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                                                   'C',
                                                                   SUM(nvl(ht.so_tien_vnd_co, 0)),
                                                                   'N-C',
                                                                   SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                                                   'C-N',
                                                                   SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                                                   0)
                                                        FROM
                                                            tbd_tc_ht                  ht
                                                            LEFT JOIN tbs_dm_mtm                 mtm ON ht.mtm_id = mtm.id
                                                            LEFT JOIN tbs_dm_dt                  dt ON ht.dttk = dt.id,
                                                            tbs_sys_bc_chi_tieu_cthuc  ctct1
                                                        WHERE
                                                                ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                                            AND ctct1.id = id_ctct
                                                            AND((ht.ma_tk IS NOT NULL
                                                                 AND REGEXP_LIKE(ht.ma_tk,
                                                                                 ctct1.thuoc_tinh_9)))
                                                            AND((ctct1.thuoc_tinh_10 IS NOT NULL
                                                                 AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                                 ctct1.thuoc_tinh_10))
                                                                OR(ctct1.thuoc_tinh_10 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_11 IS NOT NULL
                                                                 AND NOT REGEXP_LIKE(ht.ma_tk,
                                                                                     ctct1.thuoc_tinh_11))
                                                                OR(ctct1.thuoc_tinh_11 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_12 IS NOT NULL
                                                                 AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                                     ctct1.thuoc_tinh_12))
                                                                OR(ctct1.thuoc_tinh_12 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_13 IS NOT NULL
                                                                 AND ht.dttk IS NOT NULL
                                                                 AND lower(dt.ma) = '00zz')
                                                                OR(ctct1.thuoc_tinh_13 IS NULL
                                                                   AND REGEXP_LIKE(nvl(to_char(ht.dttk), 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_16 IS NOT NULL
                                                                 AND ht.mtm_id IS NOT NULL
                                                                 AND mtm.ma = ctct1.thuoc_tinh_16)
                                                                OR(ctct1.thuoc_tinh_16 IS NULL
                                                                   AND REGEXP_LIKE(nvl(to_char(ht.mtm_id), 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_4 IS NOT NULL
                                                                 AND ht.mtm_id IS NOT NULL
                                                                 AND  mtm.ma <> ctct1.thuoc_tinh_4)
                                                                OR(ctct1.thuoc_tinh_4 IS NULL
                                                                   AND REGEXP_LIKE(nvl(to_char(ht.mtm_id), 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_25 IS NULL
                                                                 AND REGEXP_LIKE(nvl(ht.ma_loai_nv, 'null'),
                                                                                 '\w*|null'))
                                                                OR(substr(ctct1.thuoc_tinh_25, 1, 3) = 'NOT'
                                                                   AND ht.ma_loai_nv NOT IN(
                                                                SELECT
                                                                    *
                                                                FROM
                                                                    split(substr(ctct1.thuoc_tinh_25, 5), ',')
                                                            ))
                                                                OR(ctct1.thuoc_tinh_25 IS NOT NULL
                                                                   AND ht.ma_loai_nv IN(
                                                                SELECT
                                                                    *
                                                                FROM
                                                                    split(ctct1.thuoc_tinh_25, ',')
                                                            )))
                                                            AND((ctct1.thuoc_tinh_20 = 'TN'
                                                                 AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900',
                                                                 'YYYY')),
                                                                                                         'YEAR'),
                                                                                                   0) AND add_months(trunc(nvl(p_nam,
                                                                                                   TO_DATE('1900', 'YYYY')),
                                                                                                                           'YEAR') -
                                                                                                                           1,
                                                                                                                     12))
                                                                OR(ctct1.thuoc_tinh_20 = '<DN'
                                                                   AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                   'YEAR'),
                                                                                               0))
                                                                OR(ctct1.thuoc_tinh_20 = '<CN'
                                                                   AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                   'YEAR') - 1,
                                                                                                12)))
                                                            AND((ctct1.thuoc_tinh_26 IS NULL
                                                                 AND REGEXP_LIKE(nvl(ht.ma_loai_kp, 'null'),
                                                                                 '\w*|null'))
                                                                OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                                                   AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                                                        GROUP BY
                                                            ctct1.thuoc_tinh_1
                                                    ) * - 1,
                                       0)))
                    FROM
                        (
                            SELECT
                                substr(t.column_value, 2)            AS id_ctct,
                                substr(t.column_value, 1, 1)         AS phep_toan
                            FROM
                                split(ctct.thuoc_tinh_3, ',') t
                        )
                )),0)                 AS so_tien
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ct.ma_bao_cao = 'TCKT_BC_52'
                AND ctct.thuoc_tinh_1 IS NULL
                AND ctct.thuoc_tinh_3 IS NOT NULL
            GROUP BY
                ct.id,
                ct.cap_tong_hop;


        --Tinh chi tieu khong co cong thuc con
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            cap_tong_hop,
            thuoc_tinh_20
        )
            SELECT
                ct.id              AS id,
                ct.cap_tong_hop    AS cap_tong_hop,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                        tbd_tc_ht   ht
                        LEFT JOIN tbs_dm_mtm  mtm ON ht.mtm_id = mtm.id
                        LEFT JOIN tbs_dm_dt   dt ON ht.dttk = dt.id
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                        AND ( ( ht.ma_tk IS NOT NULL
                                AND REGEXP_LIKE ( ht.ma_tk,
                                                  ctct.thuoc_tinh_9 ) ) )
                        AND ( ( ctct.thuoc_tinh_10 IS NOT NULL
                                AND REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                  ctct.thuoc_tinh_10 ) )
                              OR ( ctct.thuoc_tinh_10 IS NULL
                                   AND REGEXP_LIKE ( nvl(ht.ma_tk_doi_ung, 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_11 IS NOT NULL
                                AND NOT REGEXP_LIKE ( ht.ma_tk,
                                                      ctct.thuoc_tinh_11 ) )
                              OR ( ctct.thuoc_tinh_11 IS NULL
                                   AND REGEXP_LIKE ( nvl(ht.ma_tk, 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_12 IS NOT NULL
                                AND NOT REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                      ctct.thuoc_tinh_12 ) )
                              OR ( ctct.thuoc_tinh_12 IS NULL
                                   AND REGEXP_LIKE ( nvl(ht.ma_tk_doi_ung, 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_13 IS NOT NULL
                                AND ht.dttk IS NOT NULL
                                AND lower(dt.ma) = '00zz' )
                              OR ( ctct.thuoc_tinh_13 IS NULL
                                   AND REGEXP_LIKE ( nvl(to_char(ht.dttk), 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_16 IS NOT NULL
                                AND ht.mtm_id IS NOT NULL
                                AND mtm.ma = ctct.thuoc_tinh_16 )
                              OR ( ctct.thuoc_tinh_16 IS NULL
                                   AND REGEXP_LIKE ( nvl(to_char(ht.mtm_id), 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_4 IS NOT NULL
                                AND ht.mtm_id IS NOT NULL
                                AND mtm.ma <> ctct.thuoc_tinh_4 )
                              OR ( ctct.thuoc_tinh_4 IS NULL
                                   AND REGEXP_LIKE ( nvl(to_char(ht.mtm_id), 'null'),
                                                     '\w*|null' ) ) )
                        AND ( ( ctct.thuoc_tinh_25 IS NULL
                                AND REGEXP_LIKE ( nvl(ht.ma_loai_nv, 'null'),
                                                  '\w*|null' ) )
                              OR ( substr(ctct.thuoc_tinh_25, 1, 3) = 'NOT'
                                   AND ht.ma_loai_nv NOT IN (
                            SELECT
                                *
                            FROM
                                split(substr(ctct.thuoc_tinh_25, 5), ',')
                        ) )
                              OR ( ctct.thuoc_tinh_25 IS NOT NULL
                                   AND ht.ma_loai_nv IN (
                            SELECT
                                *
                            FROM
                                split(ctct.thuoc_tinh_25, ',')
                        ) ) )
                        AND ( ( ctct.thuoc_tinh_20 = 'TN'
                                AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                        'YEAR'),
                                                                  0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                          'YEAR') - 1,
                                                                                    12) )
                              OR ( ctct.thuoc_tinh_20 = '<DN'
                                   AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                               0) )
                              OR ( ctct.thuoc_tinh_20 = '<CN'
                                   AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                                                12) ) )
                        AND ( ( ctct.thuoc_tinh_26 IS NULL
                                AND REGEXP_LIKE ( nvl(ht.ma_loai_kp, 'null'),
                                                  '\w*|null' ) )
                              OR ( ctct.thuoc_tinh_26 IS NOT NULL
                                   AND ht.ma_loai_kp = ctct.thuoc_tinh_26 ) )
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),0)                  AS so_tien
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ct.ma_bao_cao = 'TCKT_BC_52'
                AND ctct.chi_tieu_id IS NOT NULL
                AND ctct.thuoc_tinh_9 IS NOT NULL;
                
                
        -- tinh tong theo cap
        SELECT
            MAX(ct.cap_tong_hop)
        INTO v_tong_cap
        FROM
            tbs_sys_bc_chi_tieu ct
        WHERE
            ct.ma_bao_cao = 'TCKT_BC_52';

        FOR v_index IN REVERSE 1..v_tong_cap LOOP             
                    -- tinh khac cap
            INSERT INTO tbr_tc_bc_002 (
                id_chi_tieu,
                cap_tong_hop,
                thuoc_tinh_20
            )
                SELECT
                    ct.id,
                    ct.cap_tong_hop,
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0))
                FROM
                    tbs_sys_bc_chi_tieu ct
                WHERE
                        ct.cap_tong_hop = v_index
                    AND ct.thuoc_tinh_2 IS NOT NULL
                    AND ct.ma_bao_cao = 'TCKT_BC_52'
                GROUP BY
                    ct.id,
                    ct.cap_tong_hop;
        END LOOP;
    END;


/*
    -- Mã/Tên ch?c n?ng: TCKT_BC_41 –THUY?T MINH BÁO CÁO TÀI CHÍNH
    -- Ng??i s?a: HoangV
    -- Ngày s?a: 10/08/2021
    */
    PROCEDURE prc_thuyet_minh_bao_cao_tai_chinh (
        p_ma_dvhq  VARCHAR2,
        p_nam      DATE,
        p_bang     VARCHAR2
    ) AS
        v_tong_cap           NUMBER;
        v_kiem_tra_khac_cap  NUMBER;
    BEGIN
        --Tinh chi tieu chi tiet
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_20,
            thuoc_tinh_21
        )
            SELECT
                ct.id    AS id,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                             tbd_tc_dvhq_kbnh kbnh
                        JOIN tbs_dm_kbnh  dmkbnh ON dmkbnh.id = kbnh.kbnh_id
                        RIGHT JOIN tbd_tc_ht    ht ON kbnh.id = ht.tkdt_nh_id
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                             ctct.thuoc_tinh_10))
                            OR(ctct.thuoc_tinh_10 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_11 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk,
                                                 ctct.thuoc_tinh_11))
                            OR(ctct.thuoc_tinh_11 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_12 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                 ctct.thuoc_tinh_12))
                            OR(ctct.thuoc_tinh_12 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_5 IS NOT NULL
                             AND ht.tkdt_nh_id IS NOT NULL
                             AND dmkbnh.loai = ctct.thuoc_tinh_5)
                            OR(ctct.thuoc_tinh_5 IS NULL
                               AND REGEXP_LIKE(nvl(to_char(ht.tkdt_nh_id), 'null'),
                                               '\w*|null')))
                        AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1, 12)
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)   AS so_cuoi_nam,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                             tbd_tc_dvhq_kbnh kbnh
                        JOIN tbs_dm_kbnh  dmkbnh ON dmkbnh.id = kbnh.kbnh_id
                        RIGHT JOIN tbd_tc_ht    ht ON kbnh.id = ht.tkdt_nh_id
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                        AND ht.tkdt_nh_id = kbnh.id
--                        AND kbnh.kbnh_id = dmkbnh.id
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                             ctct.thuoc_tinh_10))
                            OR(ctct.thuoc_tinh_10 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_11 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk,
                                                 ctct.thuoc_tinh_11))
                            OR(ctct.thuoc_tinh_11 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_12 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                 ctct.thuoc_tinh_12))
                            OR(ctct.thuoc_tinh_12 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_5 IS NOT NULL
                             AND ht.tkdt_nh_id IS NOT NULL
                             AND dmkbnh.loai = ctct.thuoc_tinh_5)
                            OR(ctct.thuoc_tinh_5 IS NULL
                               AND REGEXP_LIKE(nvl(to_char(ht.tkdt_nh_id), 'null'),
                                               '\w*|null')))
                        AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)   AS so_dau_nam
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ct.ma_bao_cao = 'TCKT_BC_41'
                AND ct.thuoc_tinh_13 = '2'
                AND ( p_bang IS NULL
                      OR ct.thuoc_tinh_10 = p_bang )
                AND ctct.thuoc_tinh_15 IS NULL
                AND ctct.chi_tieu_id IS NOT NULL
                AND ctct.thuoc_tinh_9 IS NOT NULL;


        --Tinh theo doi tuong
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_20,
            thuoc_tinh_21
        )
            SELECT
                st.id,
                nvl(SUM(decode(st.so_tien_cuoi_nam - abs(st.so_tien_cuoi_nam), 0, st.so_tien_cuoi_nam, 0)), 0)                        so_du_no_dau_nam,
                nvl(SUM(decode(st.so_tien_dau_nam - abs(st.so_tien_dau_nam), 0, st.so_tien_dau_nam, 0)), 0)                           so_du_no_dau_nam
            FROM
                (
                    SELECT
                        ct.id    AS id,
                        dttk.dttk,
                        SUM((
                            SELECT
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ht.dttk = dttk.dttk
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND((ctct.thuoc_tinh_10 IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                     ctct.thuoc_tinh_10))
                                    OR(ctct.thuoc_tinh_10 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct.thuoc_tinh_11 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk,
                                                         ctct.thuoc_tinh_11))
                                    OR(ctct.thuoc_tinh_11 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                       '\w*|null')))
                                AND((ctct.thuoc_tinh_12 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                         ctct.thuoc_tinh_12))
                                    OR(ctct.thuoc_tinh_12 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                                             12)
                            GROUP BY
                                ht.dttk,
                                ctct.thuoc_tinh_1
                        ))       so_tien_cuoi_nam,
                        SUM((
                            SELECT
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ht.dttk = dttk.dttk
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND((ctct.thuoc_tinh_10 IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                     ctct.thuoc_tinh_10))
                                    OR(ctct.thuoc_tinh_10 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct.thuoc_tinh_11 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk,
                                                         ctct.thuoc_tinh_11))
                                    OR(ctct.thuoc_tinh_11 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                       '\w*|null')))
                                AND((ctct.thuoc_tinh_12 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                         ctct.thuoc_tinh_12))
                                    OR(ctct.thuoc_tinh_12 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0)
                            GROUP BY
                                ht.dttk,
                                ctct.thuoc_tinh_1
                        ))       so_tien_dau_nam
                    FROM
                        tbs_sys_bc_chi_tieu        ct,
                        tbs_sys_bc_chi_tieu_cthuc  ctct,
                        (
                            SELECT DISTINCT
                                ht.dttk
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                ht.dttk IS NOT NULL
                        )                          dttk
                    WHERE
                            ct.id = ctct.chi_tieu_id
                        AND ct.ma_bao_cao = 'TCKT_BC_41'
                        AND ct.thuoc_tinh_13 = '2'
                        AND ctct.thuoc_tinh_15 = 'dt'
                        AND ctct.chi_tieu_id IS NOT NULL
                        AND ctct.thuoc_tinh_9 IS NOT NULL
                    GROUP BY
                        ct.id,
                        dttk.dttk
                ) st
            WHERE
                st.so_tien_cuoi_nam IS NOT NULL
                OR st.so_tien_dau_nam IS NOT NULL
            GROUP BY
                st.id;

        --Tinh bang III4
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_20,
            thuoc_tinh_21
        )
            SELECT
                tscd.id,
                SUM(decode(tscd.thuoc_tinh_15, 'hh', tscd.so_tien, 0))               tscd_huu_hinh,
                SUM(decode(tscd.thuoc_tinh_15, 'vh', tscd.so_tien, 0))               tscd_vo_hinh
            FROM
                (
                    SELECT
                        ct.id              AS id,
                        ct.cap_tong_hop    AS cap_tong_hop,
                        (
                            SELECT
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ( ( ctct.thuoc_tinh_20 = 'TN'
                                        AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                'YEAR'),
                                                                          0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                                  'YEAR') - 1,
                                                                                            12) )
                                      OR ( ctct.thuoc_tinh_20 = 'DN'
                                           AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                             'YEAR'),
                                                                       0) )
                                      OR ( ctct.thuoc_tinh_20 = 'CN'
                                           AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                              'YEAR') - 1,
                                                                        12) ) )
                            GROUP BY
                                ctct.thuoc_tinh_1
                        )                  AS so_tien,
                        ctct.thuoc_tinh_15
                    FROM
                        tbs_sys_bc_chi_tieu        ct,
                        tbs_sys_bc_chi_tieu_cthuc  ctct
                    WHERE
                            ct.id = ctct.chi_tieu_id
                        AND ct.ma_bao_cao = 'TCKT_BC_41'
                        AND ct.thuoc_tinh_13 = '3'
                        AND ( p_bang IS NULL
                              OR ct.thuoc_tinh_10 = p_bang )
                        AND ctct.chi_tieu_id IS NOT NULL
                        AND ctct.thuoc_tinh_9 IS NOT NULL
                ) tscd
            GROUP BY
                tscd.id;

        --Tinh bang III15
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            thuoc_tinh_20,
            thuoc_tinh_21,
            thuoc_tinh_22,
            thuoc_tinh_23
        )
            SELECT
                bdcnv.id,
                SUM(decode(bdcnv.thuoc_tinh_15, 'cl', bdcnv.so_tien, 0))               chenh_lech_ty_gia,
                SUM(decode(bdcnv.thuoc_tinh_15, 'td', bdcnv.so_tien, 0))               thang_du,
                SUM(decode(bdcnv.thuoc_tinh_15, 'cq', bdcnv.so_tien, 0))               cac_quy,
                SUM(decode(bdcnv.thuoc_tinh_15, 'cc', bdcnv.so_tien, 0))               nguon_cai_cach_tien_luong
            FROM
                (
                    SELECT
                        ct.id    AS id,
                        (
                            SELECT
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ( ( ctct.thuoc_tinh_10 IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                          ctct.thuoc_tinh_10 ) )
                                      OR ( ctct.thuoc_tinh_10 IS NULL
                                           AND REGEXP_LIKE ( nvl(ht.ma_tk_doi_ung, 'null'),
                                                             '\w*|null' ) ) )
                                AND ( ( ctct.thuoc_tinh_11 IS NOT NULL
                                        AND NOT REGEXP_LIKE ( ht.ma_tk,
                                                              ctct.thuoc_tinh_11 ) )
                                      OR ( ctct.thuoc_tinh_11 IS NULL
                                           AND REGEXP_LIKE ( nvl(ht.ma_tk, 'null'),
                                                             '\w*|null' ) ) )
                                AND ( ( ctct.thuoc_tinh_12 IS NOT NULL
                                        AND NOT REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                              ctct.thuoc_tinh_12 ) )
                                      OR ( ctct.thuoc_tinh_12 IS NULL
                                           AND REGEXP_LIKE ( nvl(ht.ma_tk_doi_ung, 'null'),
                                                             '\w*|null' ) ) )
                                AND ( ( ctct.thuoc_tinh_20 = 'TN'
                                        AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                'YEAR'),
                                                                          0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                                  'YEAR') - 1,
                                                                                            12) )
                                      OR ( ctct.thuoc_tinh_20 = 'DN'
                                           AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                             'YEAR'),
                                                                       0) )
                                      OR ( ctct.thuoc_tinh_20 = 'CN'
                                           AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                              'YEAR') - 1,
                                                                        12) ) )
                            GROUP BY
                                ctct.thuoc_tinh_1
                        )        AS so_tien,
                        ctct.thuoc_tinh_15
                    FROM
                        tbs_sys_bc_chi_tieu        ct,
                        tbs_sys_bc_chi_tieu_cthuc  ctct
                    WHERE
                            ct.id = ctct.chi_tieu_id
                        AND ct.ma_bao_cao = 'TCKT_BC_41'
                        AND ct.thuoc_tinh_13 = '5'
                        AND ( p_bang IS NULL
                              OR ct.thuoc_tinh_10 = p_bang )
                        AND ctct.chi_tieu_id IS NOT NULL
                        AND ctct.thuoc_tinh_9 IS NOT NULL
                ) bdcnv
            GROUP BY
                bdcnv.id;


        -- tinh tong theo cap
        SELECT
            MAX(ct.cap_tong_hop)
        INTO v_tong_cap
        FROM
            tbs_sys_bc_chi_tieu ct
        WHERE
                ct.ma_bao_cao = 'TCKT_BC_41'
            AND ( p_bang IS NULL
                  OR ct.thuoc_tinh_10 = p_bang );

        FOR v_index IN REVERSE 1..v_tong_cap LOOP             
                    -- tinh khac cap
            INSERT INTO tbr_tc_bc_002 (
                id_chi_tieu,
                cap_tong_hop,
                thuoc_tinh_20,
                thuoc_tinh_21,
                thuoc_tinh_22,
                thuoc_tinh_23
            )
                SELECT
                    ct.id,
                    ct.cap_tong_hop,
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0)),
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_21, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_21, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0)),
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_22, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_22, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0)),
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_23, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_23, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0))
                FROM
                    tbs_sys_bc_chi_tieu ct
                WHERE
                        ct.cap_tong_hop = v_index
                    AND ct.thuoc_tinh_2 IS NOT NULL
                    AND ct.ma_bao_cao = 'TCKT_BC_41'
                    AND ( p_bang IS NULL
                          OR ct.thuoc_tinh_10 = p_bang )
                GROUP BY
                    ct.id,
                    ct.cap_tong_hop;

        END LOOP;

    END;
    /*
    -- Mã/Tên ch?c n?ng: TCKT_BC_55 – BÁO CÁO K?T QU? HO?T ??NG CÓ THU
    -- Ng??i s?a: HoangV
    -- Ngày s?a: 24/08/2021
    */
    PROCEDURE prc_bao_cao_ket_qua_hoat_dong_co_thu (
        p_ma_dvhq  VARCHAR2,
        p_nam      DATE
    ) AS
        v_tong_cap NUMBER;
    BEGIN
            --Tinh chi tieu co cong thuc con
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            cap_tong_hop,
            thuoc_tinh_20
        )
            SELECT
                ct.id              AS id,
                ct.cap_tong_hop    AS cap_tong_hop,
                SUM((
                    SELECT
                        SUM(decode(phep_toan, '+', nvl((
                            SELECT
                                decode(ctct1.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0)
                            FROM
                                tbd_tc_ht                  ht,
                                tbs_sys_bc_chi_tieu_cthuc  ctct1
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND ctct1.id = id_ctct
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct1.thuoc_tinh_9)))
                                AND((ctct1.thuoc_tinh_10 IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                     ctct1.thuoc_tinh_10))
                                    OR(ctct1.thuoc_tinh_10 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_11 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk,
                                                         ctct1.thuoc_tinh_11))
                                    OR(ctct1.thuoc_tinh_11 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_12 IS NOT NULL
                                     AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                         ctct1.thuoc_tinh_12))
                                    OR(ctct1.thuoc_tinh_12 IS NULL
                                       AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                       '\w*|null')))
                                AND((ctct1.thuoc_tinh_26 IS NULL
                                     AND REGEXP_LIKE(nvl(ht.ma_loai_kp, 'null'),
                                                     '\w*|null'))
                                    OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                       AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                                AND((ctct1.thuoc_tinh_20 = 'TN'
                                     AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                             'YEAR'),
                                                                       0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                               'YEAR') - 1,
                                                                                         12))
                                    OR(ctct1.thuoc_tinh_20 = '<DN'
                                       AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                                   0))
                                    OR(ctct1.thuoc_tinh_20 = '<CN'
                                       AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                                                    12)))
                            GROUP BY
                                ctct1.thuoc_tinh_1
                        ),
                                                       0),
                                   '-',
                                   nvl((
                                                        SELECT
                                                            decode(ctct1.thuoc_tinh_1, 'N',
                                                                   SUM(nvl(ht.so_tien_vnd_no, 0)),
                                                                   'C',
                                                                   SUM(nvl(ht.so_tien_vnd_co, 0)),
                                                                   'N-C',
                                                                   SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                                                   'C-N',
                                                                   SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                                                   0)
                                                        FROM
                                                            tbd_tc_ht                  ht,
                                                            tbs_sys_bc_chi_tieu_cthuc  ctct1
                                                        WHERE
                                                                ht.ma_dvhq = nvl(p_ma_dvhq, '00')
--                                                            AND ht.dttk = dt.id
                                                            AND ctct1.id = id_ctct
                                                            AND((ht.ma_tk IS NOT NULL
                                                                 AND REGEXP_LIKE(ht.ma_tk,
                                                                                 ctct1.thuoc_tinh_9)))
                                                            AND((ctct1.thuoc_tinh_10 IS NOT NULL
                                                                 AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                                 ctct1.thuoc_tinh_10))
                                                                OR(ctct1.thuoc_tinh_10 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_11 IS NOT NULL
                                                                 AND NOT REGEXP_LIKE(ht.ma_tk,
                                                                                     ctct1.thuoc_tinh_11))
                                                                OR(ctct1.thuoc_tinh_11 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_12 IS NOT NULL
                                                                 AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                                     ctct1.thuoc_tinh_12))
                                                                OR(ctct1.thuoc_tinh_12 IS NULL
                                                                   AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                                                                   '\w*|null')))
                                                            AND((ctct1.thuoc_tinh_26 IS NULL
                                                                 AND REGEXP_LIKE(nvl(ht.ma_loai_kp, 'null'),
                                                                                 '\w*|null'))
                                                                OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                                                   AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                                                            AND((ctct1.thuoc_tinh_20 = 'TN'
                                                                 AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900',
                                                                 'YYYY')),
                                                                                                         'YEAR'),
                                                                                                   0) AND add_months(trunc(nvl(to_date(
                                                                                                   p_nam, 'yyyy'),
                                                                                                                               TO_DATE(
                                                                                                                               '1900',
                                                                                                                               'YYYY')),
                                                                                                                           'YEAR') -
                                                                                                                           1,
                                                                                                                     12))
                                                                OR(ctct1.thuoc_tinh_20 = '<DN'
                                                                   AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                                     'YEAR'),
                                                                                               0))
                                                                OR(ctct1.thuoc_tinh_20 = '<CN'
                                                                   AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                                      'YEAR') - 1,
                                                                                                12)))
                                                        GROUP BY
                                                            ctct1.thuoc_tinh_1
                                                    ) * - 1,
                                       0)))
                    FROM
                        (
                            SELECT
                                substr(t.column_value, 2)            AS id_ctct,
                                substr(t.column_value, 1, 1)         AS phep_toan
                            FROM
                                split(ctct.thuoc_tinh_3, ',') t
                        )
                ))                 AS so_tien
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ct.ma_bao_cao = 'TCKT_BC_55'
                AND ctct.thuoc_tinh_1 IS NULL
                AND ctct.thuoc_tinh_3 IS NOT NULL
            GROUP BY
                ct.id,
                ct.cap_tong_hop;

        --Tinh chi tieu khong co cong thuc con
        INSERT INTO tbr_tc_bc_002 (
            id_chi_tieu,
            cap_tong_hop,
            thuoc_tinh_20
        )
            SELECT
                ct.id              AS id,
                ct.cap_tong_hop    AS cap_tong_hop,
                nvl((
                    SELECT
                        decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'N-C',
                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                               'C-N',
                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                               0)
                    FROM
                        tbs_dm_dt  dt
                        RIGHT JOIN tbd_tc_ht  ht ON ht.dttk = dt.id
                    WHERE
                            ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                             ctct.thuoc_tinh_10))
                            OR(ctct.thuoc_tinh_10 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_11 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk,
                                                 ctct.thuoc_tinh_11))
                            OR(ctct.thuoc_tinh_11 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_12 IS NOT NULL
                             AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                 ctct.thuoc_tinh_12))
                            OR(ctct.thuoc_tinh_12 IS NULL
                               AND REGEXP_LIKE(nvl(ht.ma_tk_doi_ung, 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_15 IS NOT NULL
                             AND ht.dttk IS NOT NULL
                             AND lower(dt.ma) = '00zz')
                            OR(ctct.thuoc_tinh_15 IS NULL
                               AND REGEXP_LIKE(nvl(to_char(ht.dttk), 'null'),
                                               '\w*|null')))
                        AND((ctct.thuoc_tinh_20 = 'TN'
                             AND ht.ngay_ht BETWEEN add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'),
                                                               0) AND add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')),
                                                                                       'YEAR') - 1,
                                                                                 12))
                            OR(ctct.thuoc_tinh_20 = '<DN'
                               AND ht.ngay_ht < add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR'), 0))
                            OR(ctct.thuoc_tinh_20 = '<CN'
                               AND ht.ngay_ht <= add_months(trunc(nvl(p_nam, TO_DATE('1900', 'YYYY')), 'YEAR') - 1,
                                                            12)))
                        AND((ctct.thuoc_tinh_26 IS NULL
                             AND REGEXP_LIKE(nvl(ht.ma_loai_kp, 'null'),
                                             '\w*|null'))
                            OR(ctct.thuoc_tinh_26 IS NOT NULL
                               AND ht.ma_loai_kp = ctct.thuoc_tinh_26))
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)             AS so_tien
            FROM
                tbs_sys_bc_chi_tieu        ct,
                tbs_sys_bc_chi_tieu_cthuc  ctct
            WHERE
                    ct.id = ctct.chi_tieu_id
                AND ct.ma_bao_cao = 'TCKT_BC_55'
                AND ctct.chi_tieu_id IS NOT NULL
                AND ctct.thuoc_tinh_9 IS NOT NULL;
        
        -- tinh tong theo cap
        SELECT
            MAX(ct.cap_tong_hop)
        INTO v_tong_cap
        FROM
            tbs_sys_bc_chi_tieu ct
        WHERE
            ct.ma_bao_cao = 'TCKT_BC_55';

        FOR v_index IN REVERSE 1..v_tong_cap LOOP             
                    -- tinh khac cap
            INSERT INTO tbr_tc_bc_002 (
                id_chi_tieu,
                cap_tong_hop,
                thuoc_tinh_20
            )
                SELECT
                    ct.id,
                    ct.cap_tong_hop,
                    SUM(nvl((
                        SELECT
                            SUM(decode(phep_toan, '-',(
                                SELECT
                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                FROM
                                    tbr_tc_bc_002 dl
                                WHERE
                                    dl.id_chi_tieu = id_ct
                            ) * - 1,
                                       '+',
                                       (
                                                                SELECT
                                                                    SUM(nvl(dl.thuoc_tinh_20, 0))
                                                                FROM
                                                                    tbr_tc_bc_002 dl
                                                                WHERE
                                                                    dl.id_chi_tieu = id_ct
                                                            ),
                                       0))
                        FROM
                            (
                                SELECT
                                    substr(column_value, 2)          AS id_ct,
                                    substr(column_value, 1, 1)       AS phep_toan
                                FROM
                                    split(ct.thuoc_tinh_2, ',')
                            )
                    ),
                            0))
                FROM
                    tbs_sys_bc_chi_tieu ct
                WHERE
                        ct.cap_tong_hop = v_index
                    AND ct.thuoc_tinh_2 IS NOT NULL
                    AND ct.ma_bao_cao = 'TCKT_BC_55'
                GROUP BY
                    ct.id,
                    ct.cap_tong_hop;

        END LOOP;

    END;

END pkg_bc_dong_tckt_hoang;

/
