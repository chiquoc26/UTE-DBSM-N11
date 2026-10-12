/**
 * UTE EXPRESS LOGISTICS - INTERACTIVE COMPONENTS, HELPERS & PROTOTYPE LOGIC
 */

// 1. POPUP MODAL CONTROLS
function openModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.add('show');
        document.body.style.overflow = 'hidden';
    }
}

function closeModal(modalId) {
    const modal = document.getElementById(modalId);
    if (modal) {
        modal.classList.remove('show');
        document.body.style.overflow = '';
    }
}

// Đóng modal khi click ra ngoài vùng backdrop
document.addEventListener('click', function(e) {
    if (e.target.classList.contains('modal-backdrop')) {
        e.target.classList.remove('show');
        document.body.style.overflow = '';
    }
});

// 2. TOAST NOTIFICATION SYSTEM
function showToast(title, message, type = 'info') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }

    const toast = document.createElement('div');
    toast.className = `toast toast-${type}`;
    toast.innerHTML = `
        <div style="flex: 1;">
            <div class="toast-title">${title}</div>
            <div class="toast-msg">${message}</div>
        </div>
        <button style="background:none;border:none;cursor:pointer;color:#94A3B8;font-size:16px;" onclick="this.parentElement.remove()">✕</button>
    `;

    container.appendChild(toast);

    setTimeout(() => {
        toast.style.opacity = '0';
        toast.style.transform = 'translateX(100%)';
        toast.style.transition = 'all 0.3s ease';
        setTimeout(() => toast.remove(), 300);
    }, 3500);
}

// 3. TÍNH CƯỚC PHÍ VẬN CHUYỂN TỰ ĐỘNG
function calculateShippingFee(weightKg, lengthCm = 10, widthCm = 10, heightCm = 10, distanceKm = 10) {
    const volWeight = (lengthCm * widthCm * heightCm) / 5000;
    const chargeWeight = Math.max(parseFloat(weightKg) || 0, volWeight);
    
    let basePrice = 15000;
    if (chargeWeight > 1) {
        basePrice += Math.ceil(chargeWeight - 1) * 5000;
    }
    if (distanceKm > 10) {
        basePrice += Math.ceil(distanceKm - 10) * 1000;
    }
    return basePrice;
}

// 4. RENDER STATUS BADGE HELPER
function getStatusBadge(status) {
    switch (status) {
        case 'Hoàn thành':
        case 'Giao thành công':
        case 'Đã giao':
        case 'Hoạt động':
        case 'Đã thanh toán':
        case 'Sẵn sàng':
            return `<span class="badge badge-success"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Đang đi':
        case 'Đang thực hiện':
        case 'Đang vận chuyển':
        case 'Đang xử lý':
        case 'Đang chạy':
        case 'Đã quét':
            return `<span class="badge badge-info"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Chưa đi':
        case 'Chưa xuất phát':
        case 'Đã gán':
        case 'Mới tạo':
        case 'Đã tiếp nhận':
        case 'Đến kho':
        case 'Đang giao':
        case 'Chờ tiếp nhận':
        case 'Chưa thanh toán':
            return `<span class="badge badge-warning"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Đã hủy':
        case 'Hủy':
        case 'Trả hàng':
        case 'Bị khóa':
        case 'Thất bại':
        case 'Bảo trì':
            return `<span class="badge badge-danger"><span class="badge-dot"></span>${status}</span>`;
            
        default:
            return `<span class="badge badge-gray"><span class="badge-dot"></span>${status || 'Không rõ'}</span>`;
    }
}

// 5. BỘ ĐIỀU KHIỂN PHÂN TRANG BẢNG DỮ LIỆU (5, 10, 20 DÒNG/TRANG)
class TablePagination {
    constructor({ containerId, defaultPageSize = 5, pageSizeOptions = [5, 10, 20], onChange }) {
        this.containerId = containerId;
        this.pageSize = defaultPageSize;
        this.currentPage = 1;
        this.totalItems = 0;
        this.pageSizeOptions = pageSizeOptions;
        this.onChange = onChange;
    }

    getContainer() {
        return typeof this.containerId === 'string' ? document.getElementById(this.containerId) : this.containerId;
    }

    setPage(page) {
        const totalPages = Math.max(1, Math.ceil(this.totalItems / this.pageSize));
        if (page < 1) page = 1;
        if (page > totalPages) page = totalPages;
        if (this.currentPage !== page) {
            this.currentPage = page;
            if (typeof this.onChange === 'function') {
                this.onChange(this.currentPage, this.pageSize);
            }
        }
    }

    setPageSize(size) {
        const s = parseInt(size, 10);
        if (!isNaN(s) && this.pageSize !== s) {
            this.pageSize = s;
            this.currentPage = 1;
            if (typeof this.onChange === 'function') {
                this.onChange(this.currentPage, this.pageSize);
            }
        }
    }

    reset() {
        this.currentPage = 1;
    }

    paginate(items) {
        if (!Array.isArray(items)) items = [];
        this.totalItems = items.length;
        const totalPages = Math.max(1, Math.ceil(this.totalItems / this.pageSize));
        if (this.currentPage > totalPages) {
            this.currentPage = totalPages;
        }
        if (this.currentPage < 1) {
            this.currentPage = 1;
        }
        this.render();
        const start = (this.currentPage - 1) * this.pageSize;
        return items.slice(start, start + this.pageSize);
    }

    setServerPageInfo(info) {
        if (!info) return;
        if (info.page !== undefined) this.currentPage = info.page;
        if (info.size !== undefined) this.pageSize = info.size;
        if (info.totalItems !== undefined) this.totalItems = info.totalItems;
        this.render();
    }

    render() {
        const container = this.getContainer();
        if (!container) return;

        const totalPages = Math.max(1, Math.ceil(this.totalItems / this.pageSize));
        const startItem = this.totalItems === 0 ? 0 : (this.currentPage - 1) * this.pageSize + 1;
        const endItem = Math.min(this.currentPage * this.pageSize, this.totalItems);

        const sizeOptionsHtml = this.pageSizeOptions.map(opt => 
            `<option value="${opt}" ${opt === this.pageSize ? 'selected' : ''}>${opt} / trang</option>`
        ).join('');

        let pageNumbers = [];
        if (totalPages <= 7) {
            for (let i = 1; i <= totalPages; i++) pageNumbers.push(i);
        } else {
            pageNumbers.push(1);
            if (this.currentPage > 3) {
                pageNumbers.push('...');
            }
            const startP = Math.max(2, this.currentPage - 1);
            const endP = Math.min(totalPages - 1, this.currentPage + 1);
            for (let i = startP; i <= endP; i++) {
                if (!pageNumbers.includes(i)) pageNumbers.push(i);
            }
            if (this.currentPage < totalPages - 2) {
                pageNumbers.push('...');
            }
            if (!pageNumbers.includes(totalPages)) {
                pageNumbers.push(totalPages);
            }
        }

        const pagesButtonsHtml = pageNumbers.map(p => {
            if (p === '...') {
                return `<span class="page-btn" style="border:none; cursor:default; background:none; opacity:0.6;">...</span>`;
            }
            return `<button type="button" class="page-btn ${p === this.currentPage ? 'active' : ''}" data-page="${p}">${p}</button>`;
        }).join('');

        container.className = 'pagination-wrapper';
        container.innerHTML = `
            <div class="pagination-info">
                <span>Hiển thị <strong>${startItem} - ${endItem}</strong> trên <strong>${this.totalItems}</strong> bản ghi</span>
                <label style="display:flex; align-items:center; gap:6px; margin:0;">
                    <span style="color:var(--text-muted); font-size:12px;">Số dòng:</span>
                    <select class="pagination-size-select">
                        ${sizeOptionsHtml}
                    </select>
                </label>
            </div>
            <div class="pagination">
                <button type="button" class="page-btn btn-first" title="Trang đầu" ${this.currentPage <= 1 ? 'disabled' : ''}>«</button>
                <button type="button" class="page-btn btn-prev" title="Trang trước" ${this.currentPage <= 1 ? 'disabled' : ''}>‹</button>
                ${pagesButtonsHtml}
                <button type="button" class="page-btn btn-next" title="Trang sau" ${this.currentPage >= totalPages ? 'disabled' : ''}>›</button>
                <button type="button" class="page-btn btn-last" title="Trang cuối" ${this.currentPage >= totalPages ? 'disabled' : ''}>»</button>
            </div>
        `;

        const selectEl = container.querySelector('.pagination-size-select');
        if (selectEl) {
            selectEl.addEventListener('change', (e) => {
                this.setPageSize(e.target.value);
            });
        }

        const btnFirst = container.querySelector('.btn-first');
        if (btnFirst && !btnFirst.disabled) {
            btnFirst.addEventListener('click', () => this.setPage(1));
        }

        const btnPrev = container.querySelector('.btn-prev');
        if (btnPrev && !btnPrev.disabled) {
            btnPrev.addEventListener('click', () => this.setPage(this.currentPage - 1));
        }

        const btnNext = container.querySelector('.btn-next');
        if (btnNext && !btnNext.disabled) {
            btnNext.addEventListener('click', () => this.setPage(this.currentPage + 1));
        }

        const btnLast = container.querySelector('.btn-last');
        if (btnLast && !btnLast.disabled) {
            btnLast.addEventListener('click', () => this.setPage(totalPages));
        }

        const numBtns = container.querySelectorAll('.page-btn[data-page]');
        numBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                const p = parseInt(e.currentTarget.getAttribute('data-page'), 10);
                if (p) this.setPage(p);
            });
        });
    }
}

// 6. PROTOTYPE TOOLBAR INJECTOR (Tự động thích ứng cả chạy qua Server localhost và mở file trực tiếp)
document.addEventListener('DOMContentLoaded', () => {
    if (!document.getElementById('prototype-toolbar')) {
        const isHttp = window.location.protocol.startsWith('http');
        
        // Helper chuyển route linh hoạt
        window.navProto = function(serverRoute, fileRelativeRoute) {
            if (isHttp) {
                window.location.href = serverRoute;
            } else {
                window.location.href = fileRelativeRoute;
            }
        };

        const tb = document.createElement('div');
        tb.id = 'prototype-toolbar';
        tb.className = 'prototype-toolbar';
        tb.innerHTML = `
            <div class="proto-label">UTE Express Prototype</div>
            <select class="proto-select" id="roleNavigator" onchange="if(this.value) window.location.href=this.value">
                <option value="">-- Chọn Frame / Vai trò xem nhanh --</option>
                <optgroup label="Hệ thống & Design System">
                    <option value="${isHttp ? '/design-system' : '../design-system.html'}">00. Design System & Component Showcase</option>
                </optgroup>
                <optgroup label="1. Guest (Khách chưa đăng nhập)">
                    <option value="${isHttp ? '/' : '../guest/03-index.html'}">03. Trang chủ Public</option>
                    <option value="${isHttp ? '/tracking' : '../guest/04-tracking.html'}">04. Tra cứu đơn hàng</option>
                    <option value="${isHttp ? '/register' : '../guest/01-register.html'}">01. Đăng ký tài khoản</option>
                    <option value="${isHttp ? '/login' : '../guest/02-login.html'}">02. Đăng nhập hệ thống</option>
                </optgroup>
                <optgroup label="2. Khách hàng">
                    <option value="${isHttp ? '/customer/dashboard' : '../customer/05-dashboard.html'}">05. Dashboard Khách hàng</option>
                    <option value="${isHttp ? '/customer/create-order' : '../customer/06-create-order.html'}">06. Tạo đơn hàng (Tính cước tự động)</option>
                    <option value="${isHttp ? '/customer/order-detail' : '../customer/07-order-detail.html'}">07. Chi tiết đơn & Timeline</option>
                    <option value="${isHttp ? '/customer/payment' : '../customer/08-payment.html'}">08. Thanh toán</option>
                </optgroup>
                <optgroup label="3. Nhân viên Bưu cục">
                    <option value="${isHttp ? '/post-office/dashboard' : '../post-office/09-dashboard.html'}">09. Dashboard NV Bưu cục</option>
                    <option value="${isHttp ? '/post-office/packages' : '../post-office/10-packages.html'}">10. Quản lý kiện hàng tại kho</option>
                    <option value="${isHttp ? '/post-office/update-status' : '../post-office/11-update-status.html'}">11. Cập nhật trạng thái chuẩn luồng</option>
                </optgroup>
                <optgroup label="4. Nhân viên Điều phối">
                    <option value="${isHttp ? '/dispatcher/dashboard' : '../dispatcher/12-dashboard.html'}">12. Dashboard Điều phối</option>
                    <option value="${isHttp ? '/dispatcher/routes' : '../dispatcher/13-routes.html'}">13. Quản lý tuyến vận chuyển</option>
                    <option value="${isHttp ? '/dispatcher/trips' : '../dispatcher/14-trips.html'}">14. Quản lý chuyến giao & tải trọng</option>
                </optgroup>
                <optgroup label="5. Tài xế">
                    <option value="${isHttp ? '/driver/dashboard' : '../driver/15-dashboard.html'}">15. Dashboard Tài xế</option>
                    <option value="${isHttp ? '/driver/trip-detail' : '../driver/16-trip-detail.html'}">16. Chi tiết chuyến giao</option>
                    <option value="${isHttp ? '/driver/delivery-update' : '../driver/17-delivery-update.html'}">17. Quét kiện & Cập nhật giao</option>
                </optgroup>
                <optgroup label="6. Quản trị viên (Admin)">
                    <option value="${isHttp ? '/admin/dashboard' : '../admin/18-dashboard.html'}">18. Admin Dashboard & Chỉ số</option>
                    <option value="${isHttp ? '/admin/users' : '../admin/19-users.html'}">19. Quản lý người dùng</option>
                    <option value="${isHttp ? '/admin/warehouses' : '../admin/24-warehouses.html'}">24. Quản lý kho / bưu cục</option>
                    <option value="${isHttp ? '/admin/vehicles' : '../admin/25-vehicles.html'}">25. Quản lý phương tiện</option>
                    <option value="${isHttp ? '/admin/orders' : '../admin/27-orders.html'}">27. Giám sát đơn hàng</option>
                    <option value="${isHttp ? '/admin/payments' : '../admin/28-payments.html'}">28. Doanh thu & COD</option>
                    <option value="${isHttp ? '/admin/reports' : '../admin/29-reports.html'}">29. Báo cáo & Thống kê</option>
                    <option value="${isHttp ? '/admin/settings' : '../admin/30-settings.html'}">30. Quản trị hệ thống & Cấu hình</option>
                </optgroup>
            </select>
            <a href="${isHttp ? '/design-system' : '../design-system.html'}" class="proto-btn">Design System</a>
        `;
        document.body.appendChild(tb);
    }
});
