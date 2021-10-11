--------------------------------------------------------
--  File created - Wednesday-September-29-2021   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PKG_BC_TCKT_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "KTNB_TEST"."PKG_BC_TCKT_004" AS
    /*
    -- Mã/Tên ch?c n?ng: TCKT_BC_33 – Báo cáo tình hình tài chính
    -- Ng??i s?a: HoangV
    -- Ngày s?a: 07/07/2021
    */ PROCEDURE prc_bao_cao_tinh_hinh_tai_chinh (
        p_ma_dvhq  VARCHAR2,
        p_nam      VARCHAR2
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
                nvl((
                    SELECT
                        SUM(so_tien)
                    FROM
                        (
                            SELECT
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15,
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0) AS so_tien
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                (p_ma_dvhq IS NOT NULL
                                 AND ht.ma_dvhq = p_ma_dvhq)
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND(p_nam IS NOT NULL
                                    AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))
                            GROUP BY
                                ctct.thuoc_tinh_1,
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15
                        )
                    WHERE
                        ((ctct.thuoc_tinh_15 IN('dt', 'tk')
                          AND so_tien > 0)
                         OR ctct.thuoc_tinh_15 IS NULL)
                ),
                    0)     AS so_cuoi_nam,
                nvl(((
                    SELECT
                        nvl(SUM(so_tien_dn), 0)
                    FROM
                        (
                            SELECT
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15,
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0) AS so_tien_dn
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                    ht.ma_dvhq = nvl(p_ma_dvhq, '00')
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND(p_nam IS NOT NULL
                                    AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR'))
                            GROUP BY
                                ctct.thuoc_tinh_1,
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15
                        )
                    WHERE
                        ((ctct.thuoc_tinh_15 IN('dt', 'tk')
                          AND so_tien_dn > 0)
                         OR ctct.thuoc_tinh_15 IS NULL)
                ) +(
                    SELECT
                        nvl(SUM(so_tien_dc), 0)
                    FROM
                        (
                            SELECT
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15,
                                decode(ctct.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)), 'C',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'N-C',
                                       SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                       'C-N',
                                       SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                       0) AS so_tien_dc
                            FROM
                                tbd_tc_ht ht
                            WHERE
                                (p_ma_dvhq IS NOT NULL
                                 AND ht.ma_dvhq = p_ma_dvhq)
                                AND ht.dc_sddn = 'X'
                                AND(ht.ma_tk IS NOT NULL
                                    AND REGEXP_LIKE(ht.ma_tk,
                                                    ctct.thuoc_tinh_9))
                                AND(p_nam IS NOT NULL
                                    AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                    AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR'))
                            GROUP BY
                                ctct.thuoc_tinh_1,
                                ht.dttk,
                                ht.ma_tk,
                                ctct.thuoc_tinh_15
                        )
                    WHERE
                        ((ctct.thuoc_tinh_15 IN('dt', 'tk')
                          AND so_tien_dc > 0)
                         OR ctct.thuoc_tinh_15 IS NULL)
                )),
                    0)     so_dau_nam
            FROM
                tbs_sys_bc_chi_tieu_cthuc ctct
            WHERE
                    ctct.ma_bao_cao = 'TCKT_BC_33'
                AND ctct.thuoc_tinh_9 IS NOT NULL;
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
                        SUM((
                            SELECT
                                CASE
                                    WHEN phep_toan = '-'  THEN
                                        SUM(nvl(so_cuoi_nam, 0)) * - 1
                                    WHEN phep_toan = '+'  THEN
                                        SUM(nvl(so_cuoi_nam, 0))
                                END
                            FROM
                                (
                                    SELECT
                                        dl1.so_cuoi_nam
                                    FROM
                                        tbr_tc_bc_002              dl1,
                                        tbs_sys_bc_chi_tieu_cthuc  ctct1
                                    WHERE
                                            dl1.thuoc_tinh_11 = ctct1.id
                                        AND dl1.thuoc_tinh_11 = id_ctct
                                )
                            GROUP BY
                                phep_toan
                        ))
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
                        SUM((
                            SELECT
                                CASE
                                    WHEN phep_toan = '-'  THEN
                                        SUM(nvl(so_dau_nam, 0)) * - 1
                                    WHEN phep_toan = '+'  THEN
                                        SUM(nvl(so_dau_nam, 0))
                                END
                            FROM
                                (
                                    SELECT
                                        dl1.so_dau_nam
                                    FROM
                                        tbr_tc_bc_002              dl1,
                                        tbs_sys_bc_chi_tieu_cthuc  ctct1
                                    WHERE
                                            dl1.thuoc_tinh_11 = ctct1.id
                                        AND dl1.thuoc_tinh_11 = id_ctct
                                )
                            GROUP BY
                                phep_toan
                        ))
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
        p_nam      VARCHAR2
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
                SUM((
                    SELECT
                        SUM((
                            SELECT
                                CASE
                                    WHEN phep_toan = '-'  THEN
                                        SUM(nvl(so_tien, 0)) * - 1
                                    WHEN phep_toan = '+'  THEN
                                        SUM(nvl(so_tien, 0))
                                END
                            FROM
                                (
                                    SELECT
                                        decode(ctct1.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                               'C',
                                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                                               'N-C',
                                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                               'C-N',
                                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                               0) AS so_tien
                                    FROM
                                        tbd_tc_ht                  ht
                                        LEFT JOIN tbs_dm_mtm                 mtm ON ht.mtm_id = mtm.id
                                        LEFT JOIN tbs_dm_dt                  dt ON ht.dttk = dt.id,
                                        tbs_sys_bc_chi_tieu_cthuc  ctct1
                                    WHERE
                                        (p_ma_dvhq IS NOT NULL
                                         AND ht.ma_dvhq = p_ma_dvhq)
                                        AND ctct1.id = id_ctct
                                        AND((ht.ma_tk IS NOT NULL
                                             AND REGEXP_LIKE(ht.ma_tk,
                                                             ctct1.thuoc_tinh_9)))
                                        AND((ctct1.thuoc_tinh_10 IS NULL)
                                            OR(ctct1.thuoc_tinh_10 IS NOT NULL
                                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                               ctct1.thuoc_tinh_10)))
                                        AND((ctct1.thuoc_tinh_11 IS NULL)
                                            OR(ctct1.thuoc_tinh_11 IS NOT NULL
                                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                                   ctct1.thuoc_tinh_11)))
                                        AND((ctct1.thuoc_tinh_12 IS NULL)
                                            OR(ctct1.thuoc_tinh_12 IS NOT NULL
                                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                   ctct1.thuoc_tinh_12)))
                                        AND((ctct1.thuoc_tinh_13 IS NULL)
                                            OR(ctct1.thuoc_tinh_13 IS NOT NULL
                                               AND ht.dttk IS NOT NULL
                                               AND lower(dt.ma) = '00zz'))
                                        AND((ctct1.thuoc_tinh_16 IS NULL)
                                            OR(ctct1.thuoc_tinh_16 IS NOT NULL
                                               AND ht.mtm_id IS NOT NULL
                                               AND mtm.ma = ctct1.thuoc_tinh_16))
                                        AND((ctct1.thuoc_tinh_4 IS NULL)
                                            OR(ctct1.thuoc_tinh_4 IS NOT NULL
                                               AND ht.mtm_id IS NOT NULL
                                               AND mtm.ma <> ctct1.thuoc_tinh_4))
                                        AND((ctct1.thuoc_tinh_25 IS NULL)
                                            OR(ctct1.thuoc_tinh_25 IS NOT NULL
                                               AND substr(ctct1.thuoc_tinh_25, 1, 3) = 'NOT'
                                               AND ht.ma_loai_nv NOT IN(
                                            SELECT
                                                *
                                            FROM
                                                split(substr(ctct1.thuoc_tinh_25, 4), ',')
                                        ))
                                            OR(ctct1.thuoc_tinh_25 IS NOT NULL
                                               AND ht.ma_loai_nv IN(
                                            SELECT
                                                *
                                            FROM
                                                split(ctct1.thuoc_tinh_25, ',')
                                        )))
                                        AND((ctct1.thuoc_tinh_26 IS NULL)
                                            OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                               AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                                        AND((ctct1.thuoc_tinh_20 = 'TN'
                                             AND(p_nam IS NOT NULL
                                                 AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                                 AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                                            OR(ctct1.thuoc_tinh_20 = '<DN'
                                               AND(p_nam IS NOT NULL
                                                   AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                                            OR(ctct1.thuoc_tinh_20 = '<CN'
                                               AND(p_nam IS NOT NULL
                                                   AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
                                    GROUP BY
                                        ctct1.thuoc_tinh_1
                                )
                            GROUP BY
                                phep_toan
                        ))
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
                        (p_ma_dvhq IS NOT NULL
                         AND ht.ma_dvhq = p_ma_dvhq)
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NULL)
                            OR(ctct.thuoc_tinh_10 IS NOT NULL
                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                               ctct.thuoc_tinh_10)))
                        AND((ctct.thuoc_tinh_11 IS NULL)
                            OR(ctct.thuoc_tinh_11 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                   ctct.thuoc_tinh_11)))
                        AND((ctct.thuoc_tinh_12 IS NULL)
                            OR(ctct.thuoc_tinh_12 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_12)))
                        AND((ctct.thuoc_tinh_13 IS NULL)
                            OR(ctct.thuoc_tinh_13 IS NOT NULL
                               AND ht.dttk IS NOT NULL
                               AND lower(dt.ma) = '00zz'))
                        AND((ctct.thuoc_tinh_16 IS NULL)
                            OR(ctct.thuoc_tinh_16 IS NOT NULL
                               AND ht.mtm_id IS NOT NULL
                               AND mtm.ma = ctct.thuoc_tinh_16))
                        AND((ctct.thuoc_tinh_4 IS NULL)
                            OR(ctct.thuoc_tinh_4 IS NOT NULL
                               AND ht.mtm_id IS NOT NULL
                               AND mtm.ma <> ctct.thuoc_tinh_4))
                        AND((ctct.thuoc_tinh_25 IS NULL)
                            OR(ctct.thuoc_tinh_25 IS NOT NULL
                               AND substr(ctct.thuoc_tinh_25, 1, 3) = 'NOT'
                               AND ht.ma_loai_nv NOT IN(
                            SELECT
                                *
                            FROM
                                split(substr(ctct.thuoc_tinh_25, 4), ',')
                        ))
                            OR(ctct.thuoc_tinh_25 IS NOT NULL
                               AND ht.ma_loai_nv IN(
                            SELECT
                                *
                            FROM
                                split(ctct.thuoc_tinh_25, ',')
                        )))
                        AND((ctct.thuoc_tinh_26 IS NULL)
                            OR(ctct.thuoc_tinh_26 IS NOT NULL
                               AND ht.ma_loai_kp = ctct.thuoc_tinh_26))
                        AND((ctct.thuoc_tinh_20 = 'TN'
                             AND(p_nam IS NOT NULL
                                 AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                 AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = '<DN'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = '<CN'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
                    GROUP BY
                        ctct.thuoc_tinh_1
                ),
                    0)             AS so_tien
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
    -- Mã/Tên ch?c n?ng: TCKT_BC_41 – THUY?T MINH BÁO CÁO TÀI CHÍNH
    -- Ng??i s?a: HoangV
    -- Ngày s?a: 10/08/2021
    */
    PROCEDURE prc_thuyet_minh_bao_cao_tai_chinh (
        p_ma_dvhq  VARCHAR2,
        p_nam      VARCHAR2,
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
                        (p_ma_dvhq IS NOT NULL
                         AND ht.ma_dvhq = p_ma_dvhq)
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NULL)
                            OR(ctct.thuoc_tinh_10 IS NOT NULL
                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                               ctct.thuoc_tinh_10)))
                        AND((ctct.thuoc_tinh_11 IS NULL)
                            OR(ctct.thuoc_tinh_11 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                   ctct.thuoc_tinh_11)))
                        AND((ctct.thuoc_tinh_12 IS NULL)
                            OR(ctct.thuoc_tinh_12 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_12)))
                        AND((ctct.thuoc_tinh_5 IS NULL)
                            OR(ctct.thuoc_tinh_5 IS NOT NULL
                               AND ht.tkdt_nh_id IS NOT NULL
                               AND dmkbnh.loai = ctct.thuoc_tinh_5))
                        AND((ctct.thuoc_tinh_20 = 'DNCN'
                             AND(p_nam IS NOT NULL
                                 AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = 'NNNT'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht >= trunc((to_date(p_nam, 'YYYY')), 'YEAR')
                                   AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
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
                        (p_ma_dvhq IS NOT NULL
                         AND ht.ma_dvhq = p_ma_dvhq)
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NULL)
                            OR(ctct.thuoc_tinh_10 IS NOT NULL
                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                               ctct.thuoc_tinh_10)))
                        AND((ctct.thuoc_tinh_11 IS NULL)
                            OR(ctct.thuoc_tinh_11 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                   ctct.thuoc_tinh_11)))
                        AND((ctct.thuoc_tinh_12 IS NULL)
                            OR(ctct.thuoc_tinh_12 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_12)))
                        AND((ctct.thuoc_tinh_5 IS NULL)
                            OR(ctct.thuoc_tinh_5 IS NOT NULL
                               AND ht.tkdt_nh_id IS NOT NULL
                               AND dmkbnh.loai = ctct.thuoc_tinh_5))
                        AND ht.dc_sddn IS NULL
                        AND((ctct.thuoc_tinh_20 = 'DNCN'
                             AND(p_nam IS NOT NULL
                                 AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = 'NNNT'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht >= trunc((to_date(p_nam - 1, 'YYYY')), 'YEAR')
                                   AND ht.ngay_ht < trunc((to_date(p_nam, 'YYYY')), 'YEAR'))))
                    GROUP BY
                        ctct.thuoc_tinh_1
                ) +(
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
                        (p_ma_dvhq IS NOT NULL
                         AND ht.ma_dvhq = p_ma_dvhq)
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NULL)
                            OR(ctct.thuoc_tinh_10 IS NOT NULL
                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                               ctct.thuoc_tinh_10)))
                        AND((ctct.thuoc_tinh_11 IS NULL)
                            OR(ctct.thuoc_tinh_11 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                   ctct.thuoc_tinh_11)))
                        AND((ctct.thuoc_tinh_12 IS NULL)
                            OR(ctct.thuoc_tinh_12 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_12)))
                        AND((ctct.thuoc_tinh_5 IS NULL)
                            OR(ctct.thuoc_tinh_5 IS NOT NULL
                               AND ht.tkdt_nh_id IS NOT NULL
                               AND dmkbnh.loai = ctct.thuoc_tinh_5))
                        AND ht.dc_sddn = 'X'
                        AND(p_nam IS NOT NULL
                            AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                            AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR'))
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
                                    ht.dttk = dttk.dttk
                                AND(p_ma_dvhq IS NOT NULL
                                    AND ht.ma_dvhq = p_ma_dvhq)
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND((ctct.thuoc_tinh_10 IS NULL)
                                    OR(ctct.thuoc_tinh_10 IS NOT NULL
                                       AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                       ctct.thuoc_tinh_10)))
                                AND((ctct.thuoc_tinh_11 IS NULL)
                                    OR(ctct.thuoc_tinh_11 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk,
                                                           ctct.thuoc_tinh_11)))
                                AND((ctct.thuoc_tinh_12 IS NULL)
                                    OR(ctct.thuoc_tinh_12 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                           ctct.thuoc_tinh_12)))
                                AND((ctct.thuoc_tinh_20 = 'DNCN'
                                     AND(p_nam IS NOT NULL
                                         AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                                    OR(ctct.thuoc_tinh_20 = 'NNNT'
                                       AND(p_nam IS NOT NULL
                                           AND ht.ngay_ht >= trunc((to_date(p_nam, 'YYYY')), 'YEAR')
                                           AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
                            GROUP BY
                                ht.dttk,
                                ctct.thuoc_tinh_1
                        ))       so_tien_cuoi_nam,
                        nvl(SUM((
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
                                    ht.dttk = dttk.dttk
                                AND(p_ma_dvhq IS NOT NULL
                                    AND ht.ma_dvhq = p_ma_dvhq)
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND((ctct.thuoc_tinh_10 IS NULL)
                                    OR(ctct.thuoc_tinh_10 IS NOT NULL
                                       AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                       ctct.thuoc_tinh_10)))
                                AND((ctct.thuoc_tinh_11 IS NULL)
                                    OR(ctct.thuoc_tinh_11 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk,
                                                           ctct.thuoc_tinh_11)))
                                AND((ctct.thuoc_tinh_12 IS NULL)
                                    OR(ctct.thuoc_tinh_12 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                           ctct.thuoc_tinh_12)))
                                AND ht.dc_sddn IS NOT NULL
                                AND((ctct.thuoc_tinh_20 = 'DNCN'
                                     AND(p_nam IS NOT NULL
                                         AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                                    OR(ctct.thuoc_tinh_20 = 'NNNT'
                                       AND(p_nam IS NOT NULL
                                           AND ht.ngay_ht >= trunc((to_date(p_nam - 1, 'YYYY')), 'YEAR')
                                           AND ht.ngay_ht < trunc((to_date(p_nam, 'YYYY')), 'YEAR'))))
                            GROUP BY
                                ht.dttk,
                                ctct.thuoc_tinh_1
                        )),
                            0) + nvl(SUM((
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
                                    ht.dttk = dttk.dttk
                                AND(p_ma_dvhq IS NOT NULL
                                    AND ht.ma_dvhq = p_ma_dvhq)
                                AND((ht.ma_tk IS NOT NULL
                                     AND REGEXP_LIKE(ht.ma_tk,
                                                     ctct.thuoc_tinh_9)))
                                AND((ctct.thuoc_tinh_10 IS NULL)
                                    OR(ctct.thuoc_tinh_10 IS NOT NULL
                                       AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                       ctct.thuoc_tinh_10)))
                                AND((ctct.thuoc_tinh_11 IS NULL)
                                    OR(ctct.thuoc_tinh_11 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk,
                                                           ctct.thuoc_tinh_11)))
                                AND((ctct.thuoc_tinh_12 IS NULL)
                                    OR(ctct.thuoc_tinh_12 IS NOT NULL
                                       AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                           ctct.thuoc_tinh_12)))
                                AND ht.dc_sddn = 'X'
                                AND(p_nam IS NOT NULL
                                    AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                    AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR'))
                            GROUP BY
                                ht.dttk,
                                ctct.thuoc_tinh_1
                        )),
                                     0)       so_tien_dau_nam
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
                        SELECT tscd.id,
                 SUM(decode(tscd.thuoc_tinh_15, 'hh', tscd.so_tien, 0))               tscd_huu_hinh,
                SUM(decode(tscd.thuoc_tinh_15, 'vh', tscd.so_tien, 0))               tscd_vo_hinh
                FROM
            (SELECT
                        ct.id              AS id,
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
                                ( p_ma_dvhq IS NOT NULL
                                  AND ht.ma_dvhq = p_ma_dvhq )
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ( ( ctct.thuoc_tinh_20 = 'TN'
                                        AND ( p_nam IS NOT NULL
                                              AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                              AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR') ) )
                                      OR ( ctct.thuoc_tinh_20 = '<CN'
                                           AND ( p_nam IS NOT NULL
                                                 AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR') ) ) )
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
                        AND ctct.thuoc_tinh_20 IN ('TN','<CN')
                        AND ct.thuoc_tinh_13 = '3'
                        AND ( p_bang IS NULL
                              OR ct.thuoc_tinh_10 = p_bang )
                        AND ctct.chi_tieu_id IS NOT NULL
                        AND ctct.thuoc_tinh_9 IS NOT NULL
                    UNION ALL
                    SELECT
                        ct.id              AS id,
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
                                ( p_ma_dvhq IS NOT NULL
                                  AND ht.ma_dvhq = p_ma_dvhq )
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                                AND ht.dc_sddn IS NULL
                                AND (( p_nam IS NOT NULL
                                                 AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR') ) )
                                     
                            GROUP BY
                                ctct.thuoc_tinh_1
                        )+ nvl((SELECT
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
                                ( p_ma_dvhq IS NOT NULL
                                  AND ht.ma_dvhq = p_ma_dvhq )
                                AND ( ( ht.ma_tk IS NOT NULL
                                        AND REGEXP_LIKE ( ht.ma_tk,
                                                          ctct.thuoc_tinh_9 ) ) )
                               AND ht.dc_sddn = 'X'
                               AND (( p_nam IS NOT NULL
                                              AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                              AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR') ))
                                     
                            GROUP BY
                                ctct.thuoc_tinh_1),0)                 AS so_tien,
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
                        AND ctct.thuoc_tinh_20 IN ('<DN')
                        AND ctct.chi_tieu_id IS NOT NULL
                        AND ctct.thuoc_tinh_9 IS NOT NULL)tscd
                    GROUP BY tscd.id;
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
                            ( p_ma_dvhq IS NOT NULL
                              AND ht.ma_dvhq = p_ma_dvhq )
                            AND ( ( ht.ma_tk IS NOT NULL
                                    AND REGEXP_LIKE ( ht.ma_tk,
                                                      ctct.thuoc_tinh_9 ) ) )
                            AND ( ( ctct.thuoc_tinh_10 IS NULL )
                                  OR ( ctct.thuoc_tinh_10 IS NOT NULL
                                       AND REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                         ctct.thuoc_tinh_10 ) ) )
                            AND ( ( ctct.thuoc_tinh_11 IS NULL )
                                  OR ( ctct.thuoc_tinh_11 IS NOT NULL
                                       AND NOT REGEXP_LIKE ( ht.ma_tk,
                                                             ctct.thuoc_tinh_11 ) ) )
                            AND ( ( ctct.thuoc_tinh_12 IS NULL )
                                  OR ( ctct.thuoc_tinh_12 IS NOT NULL
                                       AND NOT REGEXP_LIKE ( ht.ma_tk_doi_ung,
                                                             ctct.thuoc_tinh_12 ) ) )
                            AND ( ( ctct.thuoc_tinh_20 = 'TN'
                                    AND ( p_nam IS NOT NULL
                                          AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                          AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR') ) )
                                  OR ( ctct.thuoc_tinh_20 = '<CN'
                                       AND ( p_nam IS NOT NULL
                                             AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR') ) ) )
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
                    AND ctct.thuoc_tinh_20 IN ( 'TN', '<CN' )
                    AND ctct.chi_tieu_id IS NOT NULL
                    AND ctct.thuoc_tinh_9 IS NOT NULL
                UNION ALL
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
                            tbd_tc_ht ht
                        WHERE
                            (p_ma_dvhq IS NOT NULL
                             AND ht.ma_dvhq = p_ma_dvhq)
                            AND((ht.ma_tk IS NOT NULL
                                 AND REGEXP_LIKE(ht.ma_tk,
                                                 ctct.thuoc_tinh_9)))
                            AND((ctct.thuoc_tinh_10 IS NULL)
                                OR(ctct.thuoc_tinh_10 IS NOT NULL
                                   AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_10)))
                            AND((ctct.thuoc_tinh_11 IS NULL)
                                OR(ctct.thuoc_tinh_11 IS NOT NULL
                                   AND NOT REGEXP_LIKE(ht.ma_tk,
                                                       ctct.thuoc_tinh_11)))
                            AND((ctct.thuoc_tinh_12 IS NULL)
                                OR(ctct.thuoc_tinh_12 IS NOT NULL
                                   AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                       ctct.thuoc_tinh_12)))
                            AND ht.dc_sddn IS NULL
                            AND((ctct.thuoc_tinh_20 = '<DN'
                                 AND(p_nam IS NOT NULL
                                     AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR'))))
                        GROUP BY
                            ctct.thuoc_tinh_1
                    ),
                        0) + nvl((
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
                            (p_ma_dvhq IS NOT NULL
                             AND ht.ma_dvhq = p_ma_dvhq)
                            AND((ht.ma_tk IS NOT NULL
                                 AND REGEXP_LIKE(ht.ma_tk,
                                                 ctct.thuoc_tinh_9)))
                            AND((ctct.thuoc_tinh_10 IS NULL)
                                OR(ctct.thuoc_tinh_10 IS NOT NULL
                                   AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_10)))
                            AND((ctct.thuoc_tinh_11 IS NULL)
                                OR(ctct.thuoc_tinh_11 IS NOT NULL
                                   AND NOT REGEXP_LIKE(ht.ma_tk,
                                                       ctct.thuoc_tinh_11)))
                            AND((ctct.thuoc_tinh_12 IS NULL)
                                OR(ctct.thuoc_tinh_12 IS NOT NULL
                                   AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                       ctct.thuoc_tinh_12)))
                            AND ht.dc_sddn = 'X'
                            AND((ctct.thuoc_tinh_20 = '<DN'
                                 AND(p_nam IS NOT NULL
                                     AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                     AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR'))))
                        GROUP BY
                            ctct.thuoc_tinh_1
                    ),
                                 0)       AS so_tien,
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
                    AND ctct.thuoc_tinh_20 IN ( '<DN' )
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
        p_nam      VARCHAR2
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
                        SUM((
                            SELECT
                                CASE
                                    WHEN phep_toan = '-'  THEN
                                        SUM(nvl(so_tien, 0)) * - 1
                                    WHEN phep_toan = '+'  THEN
                                        SUM(nvl(so_tien, 0))
                                END
                            FROM
                                (
                                    SELECT
                                        decode(ctct1.thuoc_tinh_1, 'N', SUM(nvl(ht.so_tien_vnd_no, 0)),
                                               'C',
                                               SUM(nvl(ht.so_tien_vnd_co, 0)),
                                               'N-C',
                                               SUM(nvl(ht.so_tien_vnd_no, 0)) - SUM(nvl(ht.so_tien_vnd_co, 0)),
                                               'C-N',
                                               SUM(nvl(ht.so_tien_vnd_co, 0)) - SUM(nvl(ht.so_tien_vnd_no, 0)),
                                               0) AS so_tien
                                    FROM
                                        tbd_tc_ht                  ht,
                                        tbs_sys_bc_chi_tieu_cthuc  ctct1
                                    WHERE
                                            ctct1.id = id_ctct
                                        AND(p_ma_dvhq IS NOT NULL
                                            AND ht.ma_dvhq = p_ma_dvhq)
                                        AND((ht.ma_tk IS NOT NULL
                                             AND REGEXP_LIKE(ht.ma_tk,
                                                             ctct1.thuoc_tinh_9)))
                                        AND((ctct1.thuoc_tinh_10 IS NULL)
                                            OR(ctct1.thuoc_tinh_10 IS NOT NULL
                                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                               ctct1.thuoc_tinh_10)))
                                        AND((ctct1.thuoc_tinh_11 IS NULL)
                                            OR(ctct1.thuoc_tinh_11 IS NOT NULL
                                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                                   ctct1.thuoc_tinh_11)))
                                        AND((ctct1.thuoc_tinh_12 IS NULL)
                                            OR(ctct1.thuoc_tinh_12 IS NOT NULL
                                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                                   ctct1.thuoc_tinh_12)))
                                        AND((ctct1.thuoc_tinh_26 IS NULL)
                                            OR(ctct1.thuoc_tinh_26 IS NOT NULL
                                               AND ht.ma_loai_kp = ctct1.thuoc_tinh_26))
                                        AND((ctct1.thuoc_tinh_20 = 'TN'
                                             AND(p_nam IS NOT NULL
                                                 AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                                 AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                                            OR(ctct1.thuoc_tinh_20 = '<DN'
                                               AND(p_nam IS NOT NULL
                                                   AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                                            OR(ctct1.thuoc_tinh_20 = '<CN'
                                               AND(p_nam IS NOT NULL
                                                   AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
                                    GROUP BY
                                        ctct1.thuoc_tinh_1
                                )
                            GROUP BY
                                phep_toan
                        ))
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
                        (p_ma_dvhq IS NOT NULL
                         AND ht.ma_dvhq = p_ma_dvhq)
                        AND((ht.ma_tk IS NOT NULL
                             AND REGEXP_LIKE(ht.ma_tk,
                                             ctct.thuoc_tinh_9)))
                        AND((ctct.thuoc_tinh_10 IS NULL)
                            OR(ctct.thuoc_tinh_10 IS NOT NULL
                               AND REGEXP_LIKE(ht.ma_tk_doi_ung,
                                               ctct.thuoc_tinh_10)))
                        AND((ctct.thuoc_tinh_11 IS NULL)
                            OR(ctct.thuoc_tinh_11 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk,
                                                   ctct.thuoc_tinh_11)))
                        AND((ctct.thuoc_tinh_12 IS NULL)
                            OR(ctct.thuoc_tinh_12 IS NOT NULL
                               AND NOT REGEXP_LIKE(ht.ma_tk_doi_ung,
                                                   ctct.thuoc_tinh_12)))
                        AND((ctct.thuoc_tinh_15 IS NULL)
                            OR(ctct.thuoc_tinh_15 IS NOT NULL
                               AND ht.dttk IS NOT NULL
                               AND lower(dt.ma) = '00zz'))
                        AND((ctct.thuoc_tinh_20 = 'TN'
                             AND(p_nam IS NOT NULL
                                 AND ht.ngay_ht >= trunc(to_date(p_nam, 'YYYY'), 'YEAR')
                                 AND ht.ngay_ht < trunc(to_date(p_nam + 1, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = '<DN'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht < trunc(to_date(p_nam, 'YYYY'), 'YEAR')))
                            OR(ctct.thuoc_tinh_20 = '<CN'
                               AND(p_nam IS NOT NULL
                                   AND ht.ngay_ht < trunc((to_date(p_nam + 1, 'YYYY')), 'YEAR'))))
                        AND((ctct.thuoc_tinh_26 IS NULL)
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

END pkg_bc_tckt_004;

/
