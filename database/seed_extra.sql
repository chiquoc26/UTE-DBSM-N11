-- ====================================================================
-- UTEEXPRESS - DỮ LIỆU MẪU MỞ RỘNG TOÀN DIỆN (SEED_EXTRA.SQL)
-- Dữ liệu đầy đủ chuyên sâu cho Phân hệ Điều Phối (Dispatcher) & Tài Xế (Driver).
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
-- Admin & Bưu cục
('ND001', 'admin',      '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'ADMIN',      'Hoạt động'),
('ND002', 'nvbc01',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVBC',       'Hoạt động'),
('ND003', 'nvbc02',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVBC',       'Hoạt động'),
-- Điều phối viên (Dispatcher)
('ND004', 'nvdp01',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVDP',       'Hoạt động'),
('ND009', 'nvdp02',     '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'NVDP',       'Hoạt động'),
-- Đội ngũ Tài xế (Drivers)
('ND005', 'tx01',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND006', 'tx02',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND010', 'tx03',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND011', 'tx04',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
('ND012', 'tx05',       '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'TAI_XE',     'Hoạt động'),
-- Khách hàng
('ND007', '0901000001', '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'KHACH_HANG', 'Hoạt động'),
('ND008', '0901000002', '$2a$10$BaxCyj/IY6CxGzc7aG2WauO0rOSnphOXftgCMNQDjMt2R24eUOgAi', 'KHACH_HANG', 'Hoạt động')
ON CONFLICT (ma_nd) DO UPDATE 
SET mat_khau = EXCLUDED.mat_khau, trang_thai = EXCLUDED.trang_thai;

-- 8. NHÂN VIÊN
INSERT INTO nhan_vien (ma_nv, ho_ten, chuc_vu, sdt, email, ma_kho, ma_nd) VALUES
('NV001', 'Phạm Hoàng Nam',  'Nhân viên bưu cục',   '0902000001', 'nam@uteexpress.vn',   'KHO01', 'ND002'),
('NV002', 'Võ Thị Lan',      'Nhân viên bưu cục',   '0902000002', 'lan@uteexpress.vn',   'KHO03', 'ND003'),
('NV003', 'Đặng Quốc Huy',   'Nhân viên điều phối', '0902000003', 'huy@uteexpress.vn',   'KHO01', 'ND004'),
('NV004', 'Nguyễn Thanh Tùng','Nhân viên điều phối', '0902000004', 'tung@uteexpress.vn',  'KHO03', 'ND009')
ON CONFLICT (ma_nv) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, ma_kho = EXCLUDED.ma_kho;

-- 9. KHÁCH HÀNG
INSERT INTO khach_hang (ma_kh, ho_ten, sdt, email, dia_chi_mac_dinh, ma_nd) VALUES
('KH001', 'Nguyễn Văn An', '0901000001', 'an@example.com',     '12 Võ Văn Ngân, Thủ Đức, TP.HCM', 'ND007'),
('KH002', 'Trần Thị Bích', '0901000002', 'bich@example.com',   '34 Lê Lợi, Quận 1, TP.HCM',       'ND008'),
('KH003', 'Lê Văn Cường',  '0901000003', 'cuong@example.com',  '45 Nguyễn Văn Linh, Đà Nẵng',     NULL)
ON CONFLICT (ma_kh) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, email = EXCLUDED.email;

-- 10. TÀI XẾ (5 TÀI XẾ VỚI ĐỦ CÁC HẠNG BẰNG LÁI)
INSERT INTO tai_xe (ma_tx, ho_ten, sdt, bang_lai, ma_nd) VALUES
('TX001', 'Huỳnh Văn Tài',  '0903000001', 'C',  'ND005'),
('TX002', 'Ngô Minh Đức',   '0903000002', 'E',  'ND006'),
('TX003', 'Lê Hoàng Long',  '0903000003', 'C',  'ND010'),
('TX004', 'Trần Quốc Toản', '0903000004', 'B2', 'ND011'),
('TX005', 'Nguyễn Văn Dũng','0903000005', 'E',  'ND012')
ON CONFLICT (ma_tx) DO UPDATE 
SET ho_ten = EXCLUDED.ho_ten, sdt = EXCLUDED.sdt, bang_lai = EXCLUDED.bang_lai;

-- 11. PHƯƠNG TIỆN VẬN TẢI (ĐỦ CÁC CHỦNG LOẠI XE TẢI & XE MÁY)
INSERT INTO phuong_tien (ma_pt, bien_so, loai_xe, tai_trong, trang_thai) VALUES
('PT001', '51C-123.45',  'Xe tải', 1500, 'Đang chạy'),
('PT002', '51D-678.90',  'Xe tải', 5000, 'Sẵn sàng'),
('PT003', '59H1-111.22', 'Xe máy',   30, 'Sẵn sàng'),
('PT004', '51E-999.88',  'Xe tải', 8000, 'Sẵn sàng'),
('PT005', '51C-456.78',  'Xe tải', 2500, 'Đang chạy'),
('PT006', '59H1-888.99', 'Xe máy',   30, 'Sẵn sàng'),
('PT007', '43C-333.44',  'Xe tải', 3500, 'Sẵn sàng')
ON CONFLICT (ma_pt) DO UPDATE 
SET bien_so = EXCLUDED.bien_so, tai_trong = EXCLUDED.tai_trong, trang_thai = EXCLUDED.trang_thai;

-- 12. DANH MỤC ĐƠN HÀNG MẪU (17 KỊCH BẢN ĐƠN HÀNG TOÀN DIỆN)
INSERT INTO don_hang (ma_dh, ma_kh_gui, ma_kh_nhan, sdt_nhan, ten_nguoi_nhan, dia_chi_lay, dia_chi_giao,
                      ma_kho_gui, ma_kho_nhan, ngay_tao, phi_van_chuyen, cod, ma_tt, ma_nv) VALUES
-- [Nhóm 1]: 3 đơn cơ sở ban đầu
('DH000001', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '3 hours', 35000, 150000, 'TT01', NULL),

('DH000002', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '1 day', 45000, 300000, 'TT02', 'NV001'),

('DH000003', 'KH001', 'KH002', '0901000002', 'Trần Thị Bích',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO01', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '2 days', 50000, 500000, 'TT06', 'NV001'),

-- [Nhóm 2]: Đơn đang vận chuyển liên kho CG000001 (KHO01 -> KHO03, TX001)
('DH000004', 'KH001', 'KH003', '0901000001', 'Nguyễn Thị Hoa',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '100 Hải Phòng, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '4 hours', 701000, 150000, 'TT03', 'NV001'),

-- [Nhóm 3]: Đơn đang vận chuyển liên kho CG000005 (KHO01 -> KHO04, TX003)
('DH000005', 'KH002', 'KH001', '0901000002', 'Trần Văn Nam',
 '34 Lê Lợi, Quận 1, TP.HCM', '20 Đại lộ Hòa Bình, Ninh Kiều, Cần Thơ',
 'KHO01', 'KHO04', CURRENT_TIMESTAMP - INTERVAL '6 hours', 138500, 0, 'TT03', 'NV001'),

-- [Nhóm 4]: Đơn giao cuối CG000002 tại Thủ Đức (KHO01, TX002)
('DH000006', 'KH001', 'KH002', '0901000003', 'Lê Hữu Phước',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '50 Đặng Văn Bi, Thủ Đức, TP.HCM',
 'KHO01', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '2 hours', 30000, 80000, 'TT02', 'NV001'),

-- [Nhóm 5]: Đơn giao cuối CG000006 tại Đà Nẵng (KHO03, TX004)
('DH000007', 'KH002', 'KH003', '0901000001', 'Đỗ Thanh Tùng',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '75 Bạch Đằng, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 day', 330500, 250000, 'TT05', 'NV001'),

('DH000008', 'KH001', 'KH003', '0901000002', 'Phạm Quỳnh Anh',
 '34 Lê Lợi, Quận 1, TP.HCM', '12 Lê Duẩn, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 day', 310500, 0, 'TT05', 'NV001'),

-- [Nhóm 6]: Đơn liên kho ngược CG000007 (KHO03 -> KHO01, TX005)
('DH000009', 'KH003', 'KH001', '0901000001', 'Nguyễn Văn An',
 '45 Nguyễn Văn Linh, Đà Nẵng', '12 Võ Văn Ngân, Thủ Đức, TP.HCM',
 'KHO03', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '5 hours', 425500, 0, 'TT02', 'NV002'),

-- [Nhóm 7]: Đơn liên kho CG000008 (KHO04 -> KHO01, TX001)
('DH000010', 'KH002', 'KH001', '0901000002', 'Trần Thị Mai',
 '88 Nguyễn Trãi, Ninh Kiều, Cần Thơ', '34 Lê Lợi, Quận 1, TP.HCM',
 'KHO04', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '5 hours', 153500, 300000, 'TT02', 'NV001'),

-- [Nhóm 8]: Các đơn hàng chờ Điều Phối Viên gom chuyến trên giao diện
('DH000011', 'KH001', 'KH003', '0901000001', 'Hoàng Minh Tuấn',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '150 Hùng Vương, Hải Châu, Đà Nẵng',
 'KHO01', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 hour', 120000, 200000, 'TT02', 'NV001'),

('DH000012', 'KH002', 'KH001', '0901000002', 'Vũ Thị Hạnh',
 '34 Lê Lợi, Quận 1, TP.HCM', '45 Mậu Thân, Ninh Kiều, Cần Thơ',
 'KHO01', 'KHO04', CURRENT_TIMESTAMP - INTERVAL '2 hours', 95000, 0, 'TT02', 'NV001'),

('DH000013', 'KH003', 'KH001', '0901000001', 'Lê Bích Ngọc',
 '45 Nguyễn Văn Linh, Đà Nẵng', '12 Võ Văn Ngân, Thủ Đức, TP.HCM',
 'KHO03', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '3 hours', 180000, 150000, 'TT02', 'NV002'),

('DH000014', 'KH003', 'KH002', '0901000002', 'Nguyễn Tiến Dũng',
 '45 Nguyễn Văn Linh, Đà Nẵng', '25 Trần Thái Tông, Cầu Giấy, Hà Nội',
 'KHO03', 'KHO02', CURRENT_TIMESTAMP - INTERVAL '4 hours', 210000, 0, 'TT02', 'NV002'),

('DH000015', 'KH002', 'KH001', '0901000002', 'Phan Văn Hậu',
 '88 Nguyễn Trãi, Ninh Kiều, Cần Thơ', '12 Võ Văn Ngân, Thủ Đức, TP.HCM',
 'KHO04', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '2 hours', 85000, 100000, 'TT02', 'NV001'),

('DH000016', 'KH001', 'KH003', '0901000003', 'Đặng Quốc Bảo',
 '100 Hải Phòng, Đà Nẵng', '200 Nguyễn Hữu Thọ, Cẩm Lệ, Đà Nẵng',
 'KHO03', 'KHO03', CURRENT_TIMESTAMP - INTERVAL '1 hour', 25000, 400000, 'TT02', 'NV002'),

('DH000017', 'KH002', 'KH001', '0901000002', 'Lý Gia Hân',
 '12 Võ Văn Ngân, Thủ Đức, TP.HCM', '88 Hoàng Diệu 2, Linh Chiểu, Thủ Đức',
 'KHO01', 'KHO01', CURRENT_TIMESTAMP - INTERVAL '30 minutes', 22000, 120000, 'TT02', 'NV001')
ON CONFLICT (ma_dh) DO UPDATE 
SET ma_tt = EXCLUDED.ma_tt, cod = EXCLUDED.cod, phi_van_chuyen = EXCLUDED.phi_van_chuyen;

-- 13. DANH MỤC KIỆN HÀNG MẪU TƯƠNG ỨNG
INSERT INTO kien_hang (ma_kien, ma_dh, khoi_luong, dai, rong, cao, loai_hang, ma_kho_hien_tai) VALUES
('KI0000001', 'DH000001',  2.5, 30, 20, 15, 'Đồ dùng học tập',     'KHO01'),
('KI0000002', 'DH000002',  2.0, 30, 20, 15, 'Đồ gia dụng',          'KHO01'),
('KI0000003', 'DH000003',  3.5, 40, 25, 20, 'Thiết bị điện tử',     'KHO02'),
('KI0000004', 'DH000004', 12.0, 40, 30, 20, 'Thiết bị điện tử',     NULL),    -- Đang trên xe liên kho CG000001
('KI0000005', 'DH000004',  8.0, 30, 25, 15, 'Quần áo thời trang',   NULL),    -- Đang trên xe liên kho CG000001
('KI0000006', 'DH000005', 15.0, 35, 30, 25, 'Đồ gia dụng',          NULL),    -- Đang trên xe liên kho CG000005
('KI0000007', 'DH000006',  3.5, 25, 20, 15, 'Thực phẩm hoa quả',    'KHO01'), -- Gán chuyến giao cuối CG000002
('KI0000008', 'DH000007',  6.0, 30, 20, 15, 'Giày thể thao',        'KHO03'), -- Gán chuyến giao cuối CG000006
('KI0000009', 'DH000008',  2.0, 20, 15, 10, 'Sách và tài liệu',     'KHO03'), -- Gán chuyến giao cuối CG000006
('KI0000010', 'DH000009', 25.0, 50, 40, 30, 'Hải sản khô Đà Nẵng', 'KHO03'), -- Gán chuyến liên kho CG000007
('KI0000011', 'DH000010', 18.0, 45, 35, 25, 'Trái cây đặc sản',     'KHO04'), -- Gán chuyến liên kho CG000008
-- Các kiện hàng chờ gom chuyến liên kho & giao cuối
('KI0000012', 'DH000011',  5.0, 25, 20, 15, 'Linh kiện máy tính',   'KHO01'),
('KI0000013', 'DH000011',  3.0, 20, 15, 10, 'Phụ kiện điện tử',     'KHO01'),
('KI0000014', 'DH000012',  4.0, 30, 20, 15, 'Mỹ phẩm dưỡng da',     'KHO01'),
('KI0000015', 'DH000013',  8.0, 35, 25, 20, 'Trà sâm cao cấp',      'KHO03'),
('KI0000016', 'DH000014', 10.0, 40, 30, 25, 'Thủ công mỹ nghệ',     'KHO03'),
('KI0000017', 'DH000015',  6.0, 30, 20, 15, 'Bánh pía Sóc Trăng',    'KHO04'),
('KI0000018', 'DH000016',  4.5, 25, 20, 15, 'Hàng tiêu dùng',       'KHO03'),
('KI0000019', 'DH000017',  1.8, 20, 15, 10, 'Tài liệu hợp đồng',     'KHO01')
ON CONFLICT (ma_kien) DO UPDATE 
SET ma_kho_hien_tai = EXCLUDED.ma_kho_hien_tai, khoi_luong = EXCLUDED.khoi_luong;

-- 14. CHUYẾN GIAO MẪU (8 CHUYẾN ĐA DẠNG: ĐANG CHẠY, CHỜ ĐI, HOÀN THÀNH CHO TẤT CẢ TÀI XẾ)
INSERT INTO chuyen_giao (ma_chuyen, loai_chuyen, ma_tuyen, ma_kho_giao, ma_tx, ma_pt, ma_nv_dieu_phoi,
                         ngay_xuat_phat, ngay_den_du_kien, ngay_xuat_phat_thuc, ngay_den, trang_thai) VALUES
-- Chuyến 1: Chuyến liên kho KHO01 -> KHO03 do TX001 (Huỳnh Văn Tài) lái xe PT001 (Đang đi)
('CG000001', 'LIEN_KHO', 'TU01', NULL, 'TX001', 'PT001', 'NV003',
 CURRENT_TIMESTAMP - INTERVAL '2 hours',
 CURRENT_TIMESTAMP + INTERVAL '16 hours',
 CURRENT_TIMESTAMP - INTERVAL '2 hours',
 NULL,
 'Đang đi'),

-- Chuyến 2: Chuyến giao cuối tại Thủ Đức KHO01 do TX002 (Ngô Minh Đức) lái xe máy PT003 (Chưa đi)
('CG000002', 'GIAO_CUOI', NULL, 'KHO01', 'TX002', 'PT003', 'NV003',
 CURRENT_TIMESTAMP + INTERVAL '30 minutes',
 CURRENT_TIMESTAMP + INTERVAL '4 hours',
 NULL,
 NULL,
 'Chưa đi'),

-- Chuyến 3: Chuyến liên kho ĐÃ HOÀN THÀNH của TX001 (Tạo lịch sử chuyến hoàn thành & thống kê cho TX001)
('CG000003', 'LIEN_KHO', 'TU01', NULL, 'TX001', 'PT002', 'NV003',
 CURRENT_TIMESTAMP - INTERVAL '3 days',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '3 days',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 'Hoàn thành'),

-- Chuyến 4: Chuyến giao cuối ĐÃ HOÀN THÀNH của TX002 (Tạo lịch sử giao hàng thành công cho TX002)
('CG000004', 'GIAO_CUOI', NULL, 'KHO02', 'TX002', 'PT006', 'NV003',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '3 hours',
 CURRENT_TIMESTAMP - INTERVAL '2 days',
 CURRENT_TIMESTAMP - INTERVAL '2 days' + INTERVAL '3 hours',
 'Hoàn thành'),

-- Chuyến 5: Chuyến liên kho KHO01 -> KHO04 do TX003 (Lê Hoàng Long) lái xe PT005 (Đang đi)
('CG000005', 'LIEN_KHO', 'TU04', NULL, 'TX003', 'PT005', 'NV003',
 CURRENT_TIMESTAMP - INTERVAL '1 hour',
 CURRENT_TIMESTAMP + INTERVAL '3 hours',
 CURRENT_TIMESTAMP - INTERVAL '1 hour',
 NULL,
 'Đang đi'),

-- Chuyến 6: Chuyến giao cuối tại KHO03 Đà Nẵng do TX004 (Trần Quốc Toản) lái xe PT007 (Chưa đi)
('CG000006', 'GIAO_CUOI', NULL, 'KHO03', 'TX004', 'PT007', 'NV004',
 CURRENT_TIMESTAMP + INTERVAL '1 hour',
 CURRENT_TIMESTAMP + INTERVAL '5 hours',
 NULL,
 NULL,
 'Chưa đi'),

-- Chuyến 7: Chuyến liên kho KHO03 -> KHO01 do TX005 (Nguyễn Văn Dũng) lái xe PT004 (Chưa đi)
('CG000007', 'LIEN_KHO', 'TU02', NULL, 'TX005', 'PT004', 'NV004',
 CURRENT_TIMESTAMP + INTERVAL '2 hours',
 CURRENT_TIMESTAMP + INTERVAL '20 hours',
 NULL,
 NULL,
 'Chưa đi'),

-- Chuyến 8: Chuyến liên kho kế tiếp cho TX001 (KHO04 -> KHO01, không trùng lịch với CG000001)
('CG000008', 'LIEN_KHO', 'TU05', NULL, 'TX001', 'PT001', 'NV003',
 CURRENT_TIMESTAMP + INTERVAL '24 hours',
 CURRENT_TIMESTAMP + INTERVAL '28 hours',
 NULL,
 NULL,
 'Chưa đi')
ON CONFLICT (ma_chuyen) DO UPDATE 
SET trang_thai = EXCLUDED.trang_thai, ngay_den_du_kien = EXCLUDED.ngay_den_du_kien;

-- 15. CHI TIẾT GÁN KIỆN VÀO CHUYẾN GIAO
INSERT INTO chi_tiet_chuyen_giao (ma_chuyen, ma_kien, thoi_gian_gan, thoi_gian_quet, trang_thai, ghi_chu) VALUES
-- Gán 2 kiện của đơn DH000004 vào chuyến liên kho CG000001 (TX001)
('CG000001', 'KI000004', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Đã quét', 'Đã xếp lên xe tải 51C-123.45'),
('CG000001', 'KI000005', CURRENT_TIMESTAMP - INTERVAL '2 hours', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'Đã quét', 'Đã xếp lên xe tải 51C-123.45'),

-- Gán kiện của đơn DH000006 vào chuyến giao cuối CG000002 (TX002)
('CG000002', 'KI000007', CURRENT_TIMESTAMP - INTERVAL '15 minutes', NULL, 'Đã gán', 'Chờ tài xế TX002 nhận hàng giao cuối'),

-- Chuyến hoàn thành CG000003 của TX001
('CG000003', 'KI000003', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', 'Đã giao', 'Giao thành công tại kho Cầu Giấy'),

-- Gán kiện của đơn DH000005 vào chuyến liên kho CG000005 (TX003)
('CG000005', 'KI000006', CURRENT_TIMESTAMP - INTERVAL '1 hour', CURRENT_TIMESTAMP - INTERVAL '1 hour', 'Đã quét', 'Đang vận chuyển về bưu cục Cần Thơ'),

-- Gán 2 kiện giao cuối tại Đà Nẵng vào chuyến CG000006 (TX004)
('CG000006', 'KI000008', CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL, 'Đã gán', 'Phân công giao nội thành Hải Châu'),
('CG000006', 'KI000009', CURRENT_TIMESTAMP - INTERVAL '30 minutes', NULL, 'Đã gán', 'Phân công giao lại địa chỉ cơ quan'),

-- Gán kiện vào chuyến liên kho CG000007 (TX005)
('CG000007', 'KI000010', CURRENT_TIMESTAMP - INTERVAL '10 minutes', NULL, 'Đã gán', 'Chờ xếp kiện hải sản khô lên xe tải 8T'),

-- Gán kiện vào chuyến liên kho kế tiếp CG000008 (TX001)
('CG000008', 'KI000011', CURRENT_TIMESTAMP - INTERVAL '5 minutes', NULL, 'Đã gán', 'Lập kế hoạch vận chuyển trái cây Cần Thơ')
ON CONFLICT (ma_chuyen, ma_kien) DO UPDATE 
SET trang_thai = EXCLUDED.trang_thai, ghi_chu = EXCLUDED.ghi_chu;

-- 16. GIAO DỊCH THANH TOÁN MẪU
INSERT INTO thanh_toan (ma_tt_toan, ma_dh, loai_khoan, so_tien, phuong_thuc, trang_thai, thoi_gian, nguoi_thanh_toan) VALUES
('GD000001', 'DH000003', 'PHI_VC', 50000,  'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '2 days',   'Nguyễn Văn An'),
('GD000002', 'DH000003', 'COD',    500000, 'Tiền mặt',     'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '3 hours',  'Trần Thị Bích'),
('GD000003', 'DH000004', 'PHI_VC', 701000, 'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '4 hours',  'Nguyễn Văn An'),
('GD000004', 'DH000007', 'PHI_VC', 330500, 'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '1 day',    'Trần Thị Bích'),
('GD000005', 'DH000005', 'PHI_VC', 138500, 'Chuyển khoản', 'Đã thanh toán', CURRENT_TIMESTAMP - INTERVAL '6 hours',  'Trần Văn Nam')
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
('LS00000012', 'DH000004', 'TT03', CURRENT_TIMESTAMP - INTERVAL '2 hours', 'ND004', 'Đã xếp lên chuyến xe liên kho CG000001'),
('LS00000013', 'DH000005', 'TT01', CURRENT_TIMESTAMP - INTERVAL '6 hours', 'ND008', 'Khách hàng tạo đơn qua ứng dụng'),
('LS00000014', 'DH000005', 'TT02', CURRENT_TIMESTAMP - INTERVAL '5 hours', 'ND002', 'Bưu cục Thủ Đức tiếp nhận đơn'),
('LS00000015', 'DH000005', 'TT03', CURRENT_TIMESTAMP - INTERVAL '1 hour',  'ND004', 'Đã xếp lên chuyến xe liên kho CG000005')
ON CONFLICT (ma_ls) DO NOTHING;

-- 18. ĐỒNG BỘ CÁC SEQUENCES TRÁNH XUNG ĐỘT KHI TẠO TIẾP
DO $$
BEGIN
    PERFORM setval('seq_dh',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_dh FROM 3)::BIGINT), 1) FROM don_hang WHERE ma_dh ~ '^DH[0-9]{1,6}$'), 20));
    PERFORM setval('seq_kien',   GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_kien FROM 3)::BIGINT), 1) FROM kien_hang WHERE ma_kien ~ '^KI[0-9]{1,7}$'), 20));
    PERFORM setval('seq_chuyen', GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_chuyen FROM 3)::BIGINT), 1) FROM chuyen_giao WHERE ma_chuyen ~ '^CG[0-9]{1,6}$'), 10));
    PERFORM setval('seq_ttoan',  GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_tt_toan FROM 3)::BIGINT), 1) FROM thanh_toan WHERE ma_tt_toan ~ '^(GD|TT)[0-9]{1,6}$'), 10));
    PERFORM setval('seq_ls',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_ls FROM 3)::BIGINT), 1) FROM lich_su_trang_thai WHERE ma_ls ~ '^LS[0-9]{1,8}$'), 20));
    PERFORM setval('seq_tx',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_tx FROM 3)::BIGINT), 1) FROM tai_xe WHERE ma_tx ~ '^TX[0-9]{1,4}$'), 10));
    PERFORM setval('seq_pt',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_pt FROM 3)::BIGINT), 1) FROM phuong_tien WHERE ma_pt ~ '^PT[0-9]{1,4}$'), 10));
    PERFORM setval('seq_nv',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_nv FROM 3)::BIGINT), 1) FROM nhan_vien WHERE ma_nv ~ '^NV[0-9]{1,4}$'), 10));
    PERFORM setval('seq_nd',     GREATEST((SELECT COALESCE(MAX(SUBSTRING(ma_nd FROM 3)::BIGINT), 1) FROM nguoi_dung WHERE ma_nd ~ '^ND[0-9]{1,4}$'), 15));
END $$;

COMMIT;

-- 19. BẬT LẠI TRIGGER BÌNH THƯỜNG
SET session_replication_role = 'origin';

-- THÔNG BÁO HOÀN TẤT
DO $$
BEGIN
    RAISE NOTICE '====================================================================';
    RAISE NOTICE 'NẠP TOÀN BỘ DỮ LIỆU SEED_EXTRA MỞ RỘNG THÀNH CÔNG VÀ AN TOÀN!';
    RAISE NOTICE 'Bao gồm:';
    RAISE NOTICE '- 5 tài xế (tx01 -> tx05) và 2 nhân viên điều phối (nvdp01, nvdp02)';
    RAISE NOTICE '- 7 phương tiện (xe tải 1.5T, 2.5T, 3.5T, 5T, 8T và 2 xe máy)';
    RAISE NOTICE '- 8 chuyến giao (3 Đang đi, 3 Chưa đi, 2 Hoàn thành)';
    RAISE NOTICE '- 17 đơn hàng mẫu & 19 kiện hàng (bao gồm nhiều kiện chờ điều phối gom chuyến)';
    RAISE NOTICE '- 5 giao dịch thanh toán & 15 bản ghi lịch sử trạng thái.';
    RAISE NOTICE '====================================================================';
END $$;
