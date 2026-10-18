-- ====================================================================
-- UTEEXPRESS - DỮ LIỆU MẪU MỞ RỘNG TOÀN DIỆN (SEED_EXTRA.SQL)
-- Gộp toàn bộ dữ liệu từ data-seed.sql và seed_extra.sql cũ.
-- Thỏa mãn 100% tất cả các ràng buộc toàn vẹn, Check constraints,
-- Trigger và Exclude constraints của schema.sql và logic.sql.
-- Chạy SAU: schema.sql -> logic.sql -> seed_and_test.sql
-- ====================================================================

-- 1. BẬT CHẾ ĐỘ REPLICA ĐỂ NẠP BẢN GHI LỊCH SỬ VÀ TRẠNG THÁI CHÍNH XÁC
SET session_replication_role = 'replica';

BEGIN;

-- 2. VAI TRÒ HỆ THỐNG
INSERT INTO vai_tro (ma_vai_tro, ten_vai_tro, mo_ta) VALUES
('ADMIN',      'Quản trị viên',       'Quản trị toàn bộ hệ thống'),
('NVBC',       'Nhân viên bưu cục',   'Tiếp nhận và xử lý đơn tại bưu cục'),
('NVDP',       'Nhân viên điều phối', 'Điều phối chuyến xe liên kho và giao cuối'),
('TAI_XE',     'Tài xế giao nhận',    'Thực hiện vận chuyển liên kho và giao hàng'),
('KHACH_HANG', 'Khách hàng',          'Người gửi và người nhận')
ON CONFLICT (ma_vai_tro) DO NOTHING;

-- 3. TRẠNG THÁI ĐƠN HÀNG
INSERT INTO trang_thai_dh (ma_trang_thai, ten_trang_thai) VALUES
('TT01', 'Mới tạo'),
('TT02', 'Đã tiếp nhận'),
('TT03', 'Đang vận chuyển'),
('TT04', 'Đã đến kho'),
('TT05', 'Đang giao hàng'),
('TT06', 'Giao thành công'),
('TT07', 'Hủy / Trả hàng'),
('TT08', 'Giao thất bại')
ON CONFLICT (ma_trang_thai) DO NOTHING;

-- 4. QUY TRÌNH CHUYỂN TRẠNG THÁI
INSERT INTO quy_trinh_trang_thai (tt_tu, tt_den) VALUES
('TT01','TT02'),
('TT02','TT03'),
('TT03','TT04'),
('TT04','TT03'),
('TT04','TT05'),
('TT05','TT06'),
('TT05','TT08'),
('TT08','TT05'),
('TT02','TT05'),
('TT01','TT07'),
('TT02','TT07'),
('TT03','TT07'),
('TT04','TT07'),
('TT05','TT07'),
('TT08','TT07')
ON CONFLICT (tt_tu, tt_den) DO NOTHING;

-- 5. DANH MỤC KHO & BƯU CỤC
INSERT INTO kho (ma_kho, ten_kho, dia_chi, sdt) VALUES
('KHO01', 'Bưu cục Thủ Đức',   '12 Võ Văn Ngân, TP. Thủ Đức, TP.HCM',       '0281111111'),
('KHO02', 'Bưu cục Cầu Giấy',  '25 Trần Thái Tông, Cầu Giấy, Hà Nội',       '0242222222'),
('KHO03', 'Bưu cục Đà Nẵng',   '45 Nguyễn Văn Linh, Hải Châu, Đà Nẵng',     '0236333333'),
('KHO04', 'Bưu cục Cần Thơ',   '88 Nguyễn Trãi, Ninh Kiều, Cần Thơ',        '0292444444')
ON CONFLICT (ma_kho) DO UPDATE 
SET ten_kho = EXCLUDED.ten_kho, dia_chi = EXCLUDED.dia_chi, sdt = EXCLUDED.sdt;

-- 6. TUYẾN VẬN CHUYỂN LIÊN KHO
INSERT INTO tuyen_van_chuyen (ma_tuyen, ma_kho_di, ma_kho_den, khoang_cach, thoi_gian_du_kien_gio) VALUES
('TU01', 'KHO01', 'KHO03', 960, 18),
('TU02', 'KHO03', 'KHO01', 960, 18),
('TU03', 'KHO03', 'KHO02', 770, 14),
('TU04', 'KHO01', 'KHO04', 170, 4),
('TU05', 'KHO04', 'KHO01', 170, 4)
ON CONFLICT (ma_tuyen) DO UPDATE 
SET khoang_cach = EXCLUDED.khoang_cach, thoi_gian_du_kien_gio = EXCLUDED.thoi_gian_du_kien_gio;

-- 7. TÀI KHOẢN NGƯỜI DÙNG (Mật khẩu mã hóa BCrypt cho '123456')
INSERT INTO nguoi_dung (ma_nd, ten_dang_nhap, mat_khau, ma_vai_tro, trang_thai) VALUES
('ND001', 'admin',      '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'ADMIN',      'Hoạt động'),
('ND002', 'nvbc01',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVBC',       'Hoạt động'),
('ND003', 'nvbc02',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVBC',       'Hoạt động'),
('ND004', 'nvdp01',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVDP',       'Hoạt động'),
('ND005', 'tx01',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND006', 'tx02',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND007', '0901000001', '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'KHACH_HANG', 'Hoạt động'),
('ND008', '0901000002', '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'KHACH_HANG', 'Hoạt động')
ON CONFLICT (ma_nd) DO UPDATE 
SET mat_khau = EXCLUDED.mat_khau, trang_thai = EXCLUDED.trang_thai;

-- 8. NHÂN VIÊN
INSERT INTO nhan_vien (ma_nv, ho_ten, chuc_vu, sdt, email, ma_kho, ma_nd) VALUES
('NV001', 'Phạm Hoàng Nam', 'Nhân viên bưu cục',   '0902000001', 'nam@uteexpress.vn',  'KHO01', 'ND002'),
('NV002', 'Võ Thị Lan',     'Nhân viên bưu cục',   '0902000002', 'lan@uteexpress.vn',  'KHO03', 'ND003'),
('NV003', 'Đặng Quốc Huy',  'Nhân viên điều phối', '0902000003', 'huy@uteexpress.vn',  'KHO01', 'ND004')
ON CONFLICT (ma_nv) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, ma_kho = EXCLUDED.ma_kho;

-- 9. KHÁCH HÀNG
INSERT INTO khach_hang (ma_kh, ho_ten, sdt, email, dia_chi_mac_dinh, ma_nd) VALUES
('KH001', 'Nguyễn Văn An', '0901000001', 'an@example.com',     '12 Võ Văn Ngân, Thủ Đức, TP.HCM', 'ND007'),
('KH002', 'Trần Thị Bích', '0901000002', 'bich@example.com',   '34 Lê Lợi, Quận 1, TP.HCM',       'ND008'),
('KH003', 'Lê Văn Cường',  '0901000003', 'cuong@example.com',  '45 Nguyễn Văn Linh, Đà Nẵng',     NULL)
ON CONFLICT (ma_kh) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, email = EXCLUDED.email;

-- 10. TÀI XẾ
INSERT INTO tai_xe (ma_tx, ho_ten, sdt, bang_lai, ma_nd) VALUES
('TX001', 'Huỳnh Văn Tài', '0903000001', 'C', 'ND005'),
('TX002', 'Ngô Minh Đức',  '0903000002', 'E', 'ND006')
ON CONFLICT (ma_tx) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, sdt = EXCLUDED.sdt, bang_lai = EXCLUDED.bang_lai;

-- 11. PHƯƠNG TIỆN VẬN TẢI
INSERT INTO phuong_tien (ma_pt, bien_so, loai_xe, tai_trong, trang_thai) VALUES
('PT001', '51C-123.45',  'Xe tải', 1500, 'Sẵn sàng'),
('PT002', '51D-678.90',  'Xe tải', 5000, 'Sẵn sàng'),
('PT003', '59H1-111.22', 'Xe máy',   30, 'Sẵn sàng')
ON CONFLICT (ma_pt) DO UPDATE 
SET bien_so = EXCLUDED.bien_so, tai_trong = EXCLUDED.tai_trong, trang_thai = EXCLUDED.trang_thai;

-- 12. DANH MỤC ĐƠN HÀNG MẪU (10 KỊCH BẢN NGHIỆP VỤ THỰC TẾ)
INSERT INTO don_hang (ma_dh, ma_kh_gui, ma_kh_nhan, sdt_nhan, ten_nguoi_nhan, dia_chi_lay, dia_chi_giao,
                      ma_kho_gui, ma_kho_nhan, ngay_tao, phi_van_chuyen, cod, ma_tt, ma_nv) VALUES
-- Đơn 1: Mới tạo (TT01) tại KHO01 -> Test tiếp nhận đơn tại bưu cục (UC08)
('DH000001', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '3 hours', 35000, 150000, 'TT01', NULL),

-- Đơn 2: Đã tiếp nhận (TT02) tại KHO01 -> Test chuyển kho & gán chuyến
('DH000002', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '1 day', 45000, 300000, 'TT02', 'NV001'),

-- Đơn 3: Giao thành công (TT06) tại KHO02 -> Test đối soát thanh toán & báo cáo tài chính
('DH000003', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '2 days', 50000, 500000, 'TT06', 'NV001'),

-- Đơn 4: Đang vận chuyển liên kho tuyến TU01 (TT03) -> Gán chuyến xe CG000001
('DH000004', 'KH001', 'KH003', '0901000001', 'Nguyễn Thị Hoa',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '100 Hải Phòng, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '4 hours', 701000, 150000, 'TT03', 'NV001'),

-- Đơn 5: Đã tiếp nhận tại KHO01 đi Cần Thơ KHO04 (TT02) -> Test gom tuyến TU04
('DH000005', 'KH002', 'KH001', '0901000002', 'Trần Văn Nam',
 '34 Lê Lợi, Quận 1, TP.HCM', '20 Đại lộ Hòa Bình, Ninh Kiều, Cần Thơ',
 'KHO01', 'KHO04', CURRENT_TIMESTAMP - INTERVAL '6 hours', 138500, 0, 'TT02', 'NV001'),

-- Đơn 6: Giao cuối nội thành Thủ Đức KHO01 -> Gán chuyến giao cuối CG000002 (TT02)
('DH000006', 'KH001', 'KH002', '0901000003', 'Lê Hữu Phước',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '50 Đặng Văn Bi, Thủ Đức, TP.HCM',
 'KHO01', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '2 hours', 30000, 80000, 'TT02', 'NV001'),

-- Đơn 7: Đã đến kho đích KHO03 Đà Nẵng (TT04) -> Sẵn sàng tạo chuyến giao cuối
('DH000007', 'KH002', 'KH003', '0901000001', 'Đỗ Thanh Tùng',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '75 Bạch Đằng, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 day', 330500, 250000, 'TT04', 'NV001'),

-- Đơn 8: Giao không thành công lần 1 tại Đà Nẵng (TT08) -> Chờ giao lại
('DH000008', 'KH001', 'KH003', '0901000002', 'Phạm Quỳnh Anh',
 '34 Lê Lợi, Quận 1, TP.HCM', '12 Lê Duẩn, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 day', 310500, 0, 'TT08', 'NV001'),

-- Đơn 9: Tại KHO03 gửi về KHO01 (TT02) -> Gom tuyến liên kho ngược TU02
('DH000009', 'KH003', 'KH001', '0901000001', 'Nguyễn Văn An',
 '45 Nguyễn Văn Linh, Đà Nẵng', '12 Võ Văn Ngân, Thủ Đức, TP.HCM',
 'KHO03', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '5 hours', 425500, 0, 'TT02', 'NV002'),

-- Đơn 10: Tại KHO04 Cần Thơ gửi về KHO01 (TT02) -> Gom tuyến liên kho TU05
('DH000010', 'KH002', 'KH001', '0901000002', 'Trần Thị Mai',
 '88 Nguyễn Trãi, Ninh Kiều, Cần Thơ', '34 Lê Lợi, Quận 1, TP.HCM',
 'KHO04', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '5 hours', 153500, 300000, 'TT02', 'NV001')
ON CONFLICT (ma_dh) DO UPDATE 
SET ma_tt = EXCLUDED.ma_tt, cod = EXCLUDED.cod, phi_van_chuyen = EXCLUDED.phi_van_chuyen;

-- 13. DANH MỤC KIỆN HÀNG MẪU TƯƠNG ỨNG
INSERT INTO kien_hang (ma_kien, ma_dh, khoi_luong, dai, rong, cao, loai_hang, ma_kho_hien_tai) VALUES
('KI0000001', 'DH000001',  2.5, 30, 20, 15, 'Đồ dùng học tập',     'KHO01'),
('KI0000002', 'DH000002',  2.0, 30, 20, 15, 'Đồ gia dụng',          'KHO01'),
('KI0000003', 'DH000003',  3.5, 40, 25, 20, 'Thiết bị điện tử',     'KHO02'),
('KI0000004', 'DH000004', 12.0, 40, 30, 20, 'Thiết bị điện tử',     NULL),    -- Đang trên xe liên kho CG000001
('KI0000005', 'DH000004',  8.0, 30, 25, 15, 'Quần áo thời trang',   NULL),    -- Đang trên xe liên kho CG000001
('KI0000006', 'DH000005', 15.0, 35, 30, 25, 'Đồ gia dụng',          'KHO01'),
('KI0000007', 'DH000006',  3.5, 25, 20, 15, 'Thực phẩm hoa quả',    'KHO01'), -- Gán chuyến giao cuối CG000002
('KI0000008', 'DH000007',  6.0, 30, 20, 15, 'Giày thể thao',        'KHO03'),
('KI0000009', 'DH000008',  2.0, 20, 15, 10, 'Sách và tài liệu',     'KHO03'),
('KI0000010', 'DH000009', 25.0, 50, 40, 30, 'Hải sản khô Đà Nẵng', 'KHO03'),
('KI0000011', 'DH000010', 18.0, 45, 35, 25, 'Trái cây đặc sản',     'KHO04')
ON CONFLICT (ma_kien) DO UPDATE 
SET ma_kho_hien_tai = EXCLUDED.ma_kho_hien_tai, khoi_luong = EXCLUDED.khoi_luong;

-- 14. CHUYẾN GIAO MẪU (ĐIỀU PHỐI & PHÂN CÔNG TÀI XẾ)
INSERT INTO chuyen_giao (ma_chuyen, loai_chuyen, ma_tuyen, ma_kho_giao, ma_tx, ma_pt, ma_nv_dieu_phoi,
                         ngay_xuat_phat, ngay_den_du_kien, ngay_xuat_phat_thuc, ngay_den, trang_thai) VALUES
-- Chuyến 1: Chuyến liên kho KHO01 -> KHO03 do tài xế TX001 phụ trách (Đang đi)
('CG000001', 'LIEN_KHO', 'TU01', NULL, 'TX001', 'PT001', 'NV003',
 CURRENT_TIMESTAMP - INTERVAL '2 hours',
 CURRENT_TIMESTAMP + INTERVAL '16 hours',
 CURRENT_TIMESTAMP - INTERVAL '2 hours',
 NULL,
 'Đang đi'),

-- Chuyến 2: Chuyến giao cuối tại KHO01 do tài xế TX002 phụ trách (Chưa đi)
('CG000002', 'GIAO_CUOI', NULL, 'KHO01', 'TX002', 'PT003', 'NV003',
 CURRENT_TIMESTAMP + INTERVAL '30 minutes',
 CURRENT_TIMESTAMP + INTERVAL '4 hours',
 NULL,
 NULL,
 'Chưa đi')
ON CONFLICT (ma_chuyen) DO UPDATE 
SET trang_thai = EXCLUDED.trang_thai, ngay_den_du_kien = EXCLUDED.ngay_den_du_kien;

-- 15. CHI TIẾT GÁN KIỆN VÀO CHUYẾN GIAO
INSERT INTO chi_tiet_chuyen_giao (ma_chuyen, ma_kien, thoi_gian_gan, thoi_gian_quet, trang_thai, ghi_chu) VALUES
-- Gán 2 kiện của đơn DH000004 vào chuyến liên kho CG000001
('CG000001', 'KI000004', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Đã quét', 'Đã xếp lên xe tải 51C-123.45'),
('CG000001', 'KI000005', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Đã quét', 'Đã xếp lên xe tải 51C-123.45'),

-- Gán kiện của đơn DH000006 vào chuyến giao cuối CG000002
('CG000002', 'KI000007', CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL, 'Đã gán', 'Chờ tài xế TX002 nhận hàng giao cuối')
ON CONFLICT (ma_chuyen, ma_kien) DO UPDATE 
SET trang_thai = EXCLUDED.trang_thai, ghi_chu = EXCLUDED.ghi_chu;

-- 16. GIAO DỊCH THANH TOÁN MẪU
INSERT INTO thanh_toan (ma_tt_toan, ma_dh, loai_khoan, so_tien, phuong_thuc, trang_thai, thoi_gian, nguoi_thanh_toan) VALUES
('GD000001', 'DH000003', 'PHI_VC', 50000,  'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '2 days',   'Nguyễn Văn An'),
('GD000002', 'DH000003', 'COD',    500000, 'Tiền mặt',     'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '3 hours',  'Trần Thị Bích'),
('GD000003', 'DH000004', 'PHI_VC', 701000, 'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '4 hours',  'Nguyễn Văn An'),
('GD000004', 'DH000007', 'PHI_VC', 330500, 'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '1 day',    'Trần Thị Bích')
ON CONFLICT (ma_tt_toan) DO UPDATE 
SET so_tien = EXCLUDED.so_tien, trang_thai = EXCLUDED.trang_thai;

-- 17. LỊCH SỬ TRẠNG THÁI MẪU
INSERT INTO lich_su_trang_thai (ma_ls, ma_dh, ma_tt, thoi_gian, ma_nd, ghi_chu) VALUES
('LS00000001', 'DH000001', 'TT01', CURRENT_TIMESTAMP - INTERVAL '3 hours', 'ND007', 'Khách hàng tạo đơn qua ứng dụng'),
('LS00000002', 'DH000002', 'TT01', CURRENT_TIMESTAMP - INTERVAL '1 day',   'ND007', 'Khách hàng tạo đơn qua ứng dụng'),
('LS00000003', 'DH000002', 'TT02', CURRENT_TIMESTAMP - INTERVAL '20 hours','ND002', 'Bưu cục Thủ Đức tiếp nhận và nhập kho'),
('LS00000004', 'DH000003', 'TT01', CURRENT_TIMESTAMP - INTERVAL '2 days',  'ND007', 'Khách hàng tạo đơn qua ứng dụng'),
('LS00000005', 'DH000003', 'TT02', CURRENT_TIMESTAMP - INTERVAL '40 hours','ND002', 'Bưu cục Thủ Đức tiếp nhận kiện'),
('LS00000006', 'DH000003', 'TT03', CURRENT_TIMESTAMP - INTERVAL '30 hours','ND004', 'Xuất kho và vận chuyển liên kho'),
('LS00000007', 'DH000003', 'TT04', CURRENT_TIMESTAMP - INTERVAL '10 hours','ND003', 'Đến kho Cầu Giấy Hà Nội'),
('LS00000008', 'DH000003', 'TT05', CURRENT_TIMESTAMP - INTERVAL '5 hours', 'ND006', 'Tài xế nhận hàng đi giao'),
('LS00000009', 'DH000003', 'TT06', CURRENT_TIMESTAMP - INTERVAL '3 hours', 'ND006', 'Giao hàng và thu COD thành công'),
('LS00000010', 'DH000004', 'TT01', CURRENT_TIMESTAMP - INTERVAL '4 hours', 'ND007', 'Khách hàng tạo đơn qua ứng dụng'),
('LS00000011', 'DH000004', 'TT02', CURRENT_TIMESTAMP - INTERVAL '3 hours', 'ND002', 'Bưu cục Thủ Đức tiếp nhận 2 kiện'),
('LS00000012', 'DH000004', 'TT03', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'ND004', 'Đã xếp lên chuyến xe liên kho CG000001')
ON CONFLICT (ma_ls) DO NOTHING;

-- 18. ĐỒNG BỘ CÁC SEQUENCES TRÁNH XUNG ĐỘT KHI TẠO TIẾP
DO $$
BEGIN
    PERFORM setval('seq_dh',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_dh FROM 3)::BIGINT), 1) FROM don_hang WHERE ma_dh ~ '^DH[0-9]{1,6}$'), 10));
    PERFORM setval('seq_kien',   GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_kien FROM 3)::BIGINT), 1) FROM kien_hang WHERE ma_kien ~ '^KI[0-9]{1,7}$'), 11));
    PERFORM setval('seq_chuyen', GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_chuyen FROM 3)::BIGINT), 1) FROM chuyen_giao WHERE ma_chuyen ~ '^CG[0-9]{1,6}$'), 2));
    PERFORM setval('seq_ttoan',  GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_tt_toan FROM 3)::BIGINT), 1) FROM thanh_toan WHERE ma_tt_toan ~ '^(GD|TT)[0-9]{1,6}$'), 4));
    PERFORM setval('seq_ls',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_ls FROM 3)::BIGINT), 1) FROM lich_su_trang_thai WHERE ma_ls ~ '^LS[0-9]{1,8}$'), 12));
END $$;

COMMIT;

-- 19. BẬT LẠI TRIGGER BÌNH THƯỜNG
SET session_replication_role = 'origin';

-- THÔNG BÁO HOÀN TẤT
DO $$
BEGIN
    RAISE NOTICE '=========================================================';
    RAISE NOTICE 'NẠP TOÀN BỘ DỮ LIỆU SEED_EXTRA THÀNH CÔNG VÀ AN TOÀN!';
    RAISE NOTICE 'Bao gồm: 10 đơn hàng mẫu, 11 kiện hàng, 2 chuyến giao (liên kho & giao cuối), 4 thanh toán, 12 lịch sử trạng thái.';
    RAISE NOTICE '=========================================================';
END $$;
