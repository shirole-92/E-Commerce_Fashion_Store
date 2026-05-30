/**
 * FashionStore Toast Notification System
 * Usage: Toast.show('Message')
 *        Toast.success('Added to cart')
 *        Toast.error('Something went wrong')
 *        Toast.warning('Only 2 left in stock')
 *        Toast.info('Free delivery above ₹999')
 *
 * With subtitle:
 *        Toast.success('Order placed!', 'We will ship within 2 days')
 */

const Toast = (() => {

  // Create container once
  let container = null;

  function getContainer() {
    if (!container) {
      container = document.createElement('div');
      container.className = 'toast-container';
      document.body.appendChild(container);
    }
    return container;
  }

  // Icon symbols per type
  const icons = {
    success: '✓',
    error:   '✕',
    warning: '!',
    info:    '★',
  };

  /**
   * Show a toast
   * @param {string} message   - Main message
   * @param {string} sub       - Optional subtitle
   * @param {string} type      - success | error | warning | info
   * @param {number} duration  - ms before auto-dismiss (default 3500)
   */
  function show(message, sub = '', type = 'info', duration = 3500) {

    const c = getContainer();

    // Build toast element
    const toast = document.createElement('div');
    toast.className = `toast toast--${type}`;
    toast.setAttribute('role', 'alert');
    toast.setAttribute('aria-live', 'assertive');

    toast.innerHTML = `
      <div class="toast-icon">${icons[type] || '●'}</div>
      <div class="toast-body">
        <p class="toast-title">${message}</p>
        ${sub ? `<p class="toast-sub">${sub}</p>` : ''}
      </div>
      <button class="toast-close" aria-label="Dismiss">&times;</button>
      <div class="toast-progress" style="animation-duration:${duration}ms; color:${getProgressColor(type)}"></div>
    `;

    c.appendChild(toast);

    // Animate in
    requestAnimationFrame(() => {
      requestAnimationFrame(() => toast.classList.add('toast--show'));
    });

    // Dismiss on click anywhere on toast
    toast.addEventListener('click', () => dismiss(toast));

    // Auto dismiss
    const timer = setTimeout(() => dismiss(toast), duration);

    // Close button stops timer
    toast.querySelector('.toast-close').addEventListener('click', (e) => {
      e.stopPropagation();
      clearTimeout(timer);
      dismiss(toast);
    });

    return toast;
  }

  function dismiss(toast) {
    toast.classList.remove('toast--show');
    toast.classList.add('toast--hide');
    toast.addEventListener('transitionend', () => toast.remove(), { once: true });
  }

  function getProgressColor(type) {
    const colors = {
      success: '#2ecc71',
      error:   '#c0392b',
      warning: '#e67e22',
      info:    '#c9a84c',
    };
    return colors[type] || '#c9a84c';
  }

  // ── Check for flash messages from server on page load ──
  // Pages can embed: <meta name="toast-message" content="..." data-type="success">
  document.addEventListener('DOMContentLoaded', () => {

    const meta = document.querySelector('meta[name="toast-message"]');
    if (meta) {
      const msg  = meta.getAttribute('content');
      const type = meta.getAttribute('data-type') || 'info';
      const sub  = meta.getAttribute('data-sub')  || '';
      if (msg) show(msg, sub, type);
    }

    // ── Auto-wire add-to-cart forms ──
    document.querySelectorAll('[data-toast-form]').forEach(form => {
      form.addEventListener('submit', (e) => {
        const msg  = form.dataset.toastMessage || 'Done';
        const type = form.dataset.toastType    || 'success';
        const sub  = form.dataset.toastSub     || '';
        // Small delay so user sees toast before redirect
        setTimeout(() => show(msg, sub, type), 100);
      });
    });

    // ── Auto-wire buttons with data-toast ──
    document.querySelectorAll('[data-toast]').forEach(btn => {
      btn.addEventListener('click', () => {
        const msg  = btn.dataset.toast;
        const type = btn.dataset.toastType || 'info';
        const sub  = btn.dataset.toastSub  || '';
        show(msg, sub, type);
      });
    });

  });

  return {
    show,
    success: (msg, sub, duration) => show(msg, sub, 'success', duration),
    error:   (msg, sub, duration) => show(msg, sub, 'error',   duration),
    warning: (msg, sub, duration) => show(msg, sub, 'warning', duration),
    info:    (msg, sub, duration) => show(msg, sub, 'info',    duration),
  };

})();


// ── BACK TO TOP BUTTON ─────────────────────────────────────
(function() {
  // Create button
  const btn = document.createElement('button');
  btn.innerHTML = '&#8679;';
  btn.setAttribute('aria-label', 'Back to top');
  btn.style.cssText = `
    position: fixed;
    bottom: 32px;
    right: 32px;
    z-index: 8888;
    width: 44px;
    height: 44px;
    border-radius: 50%;
    background: #c9a84c;
    color: #0a0a0a;
    border: none;
    font-size: 20px;
    font-weight: 700;
    cursor: pointer;
    display: flex;
    align-items: center;
    justify-content: center;
    box-shadow: 0 4px 16px rgba(0,0,0,0.4);
    opacity: 0;
    transform: translateY(12px);
    transition: opacity 0.3s ease, transform 0.3s ease, background 0.2s ease;
    pointer-events: none;
  `;

  document.body.appendChild(btn);

  // Show/hide on scroll
  window.addEventListener('scroll', () => {
    if (window.scrollY > 300) {
      btn.style.opacity = '1';
      btn.style.transform = 'translateY(0)';
      btn.style.pointerEvents = 'auto';
    } else {
      btn.style.opacity = '0';
      btn.style.transform = 'translateY(12px)';
      btn.style.pointerEvents = 'none';
    }
  });

  // Scroll to top on click
  btn.addEventListener('click', () => {
    window.scrollTo({ top: 0, behavior: 'smooth' });
  });

  // Hover effect
  btn.addEventListener('mouseover', () => btn.style.background = '#d4b05a');
  btn.addEventListener('mouseout',  () => btn.style.background = '#c9a84c');
})();