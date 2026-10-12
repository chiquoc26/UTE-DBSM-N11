/**
 * UTE EXPRESS LOGISTICS - INTERACTIVE COMPONENTS & PROTOTYPE LOGIC
 */

// 1. MODAL CONTROLS
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

// Close when clicking outside
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
        case 'Giao thành công':
        case 'Hoạt động':
        case 'Đã thanh toán':
        case 'Sẵn sàng':
            return `<span class="badge badge-success"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Đang vận chuyển':
        case 'Đang xử lý':
        case 'Đang chạy':
            return `<span class="badge badge-info"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Mới tạo':
        case 'Đã tiếp nhận':
        case 'Đến kho':
        case 'Đang giao':
        case 'Chờ tiếp nhận':
        case 'Chưa thanh toán':
            return `<span class="badge badge-warning"><span class="badge-dot"></span>${status}</span>`;
            
        case 'Hủy':
        case 'Trả hàng':
        case 'Bị khóa':
        case 'Thất bại':
        case 'Bảo trì':
            return `<span class="badge badge-danger"><span class="badge-dot"></span>${status}</span>`;
            
        default:
            return `<span class="badge badge-gray"><span class="badge-dot"></span>${status}</span>`;
    }
}


