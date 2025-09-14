// Minimal JS for onboarding slider and small helpers

// Global micro-interactions and onboarding slider utilities

// Page enter animation class
document.addEventListener('DOMContentLoaded', ()=>{
  document.body.classList.add('page-enter');

  // Tap ripple for buttons (only when not reduced motion)
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if(!reduced){
    const rippleTargets = document.querySelectorAll('.btn, .chip, .icon-btn');
    rippleTargets.forEach(el => {
      el.addEventListener('click', (e)=>{
        const r = document.createElement('span');
        const rect = el.getBoundingClientRect();
        const size = Math.max(rect.width, rect.height);
        const x = (e.clientX ?? rect.width/2) - rect.left - size/2;
        const y = (e.clientY ?? rect.height/2) - rect.top - size/2;
        r.style.position = 'absolute';
        r.style.left = x + 'px';
        r.style.top = y + 'px';
        r.style.width = r.style.height = size + 'px';
        r.style.borderRadius = '50%';
        r.style.background = 'rgba(46,125,91,0.18)';
        r.style.transform = 'scale(0)';
        r.style.pointerEvents = 'none';
        r.style.transition = 'transform .42s ease, opacity .6s ease';
        r.className = 'ripple';
        el.style.position = el.style.position || 'relative';
        el.style.overflow = 'hidden';
        el.appendChild(r);
        requestAnimationFrame(()=>{
          r.style.transform = 'scale(2.2)';
          r.style.opacity = '0';
        });
        setTimeout(()=> r.remove(), 650);
      });
    });
  }
});

// Intercept navigation for smoother transitions on same-origin links
document.addEventListener('click', (e)=>{
  const a = e.target.closest?.('a[href]');
  if(!a) return;
  const url = new URL(a.href, location.href);
  const sameOrigin = url.origin === location.origin;
  const fileNav = url.pathname.endsWith('.html');
  if(sameOrigin && fileNav && !a.hasAttribute('download') && !a.target){
    e.preventDefault();
    document.body.classList.remove('page-enter');
    document.body.classList.add('page-exit');
    setTimeout(()=> { window.location.href = a.href; }, 120);
  }
}, true);

// Reveal-on-scroll for elements with .reveal
(function(){
  const els = Array.from(document.querySelectorAll('.reveal'));
  if(!els.length) return;
  const reduced = window.matchMedia('(prefers-reduced-motion: reduce)').matches;
  if(reduced){
    els.forEach(el => el.classList.add('is-visible'));
    return;
  }
  const io = new IntersectionObserver((entries)=>{
    entries.forEach(entry => {
      if(entry.isIntersecting){
        entry.target.classList.add('is-visible');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.08, rootMargin: '40px' });
  els.forEach((el, idx)=>{
    el.style.setProperty('--i', String(idx % 6));
    io.observe(el);
  });
})();

// Onboarding simple slider (only if present)
(function(){
  const root = document.querySelector('[data-slider]');
  if(!root) return;
  const slides = Array.from(root.querySelectorAll('[data-slide]'));
  const dots = Array.from(root.querySelectorAll('[data-dot]'));
  const nextBtn = root.querySelector('[data-next]');
  const skipBtn = document.querySelector('[data-skip]');
  let i = 0;

  function setSlide(n){
    i = Math.max(0, Math.min(slides.length-1, n));
    slides.forEach((s,idx)=>{
      const showing = idx===i;
      s.hidden = !showing;
      if(showing){
        s.classList.add('reveal','is-visible');
      }
    });
    dots.forEach((d,idx)=> d.setAttribute('aria-current', idx===i ? 'true' : 'false'));
    if(nextBtn) nextBtn.textContent = (i===slides.length-1) ? 'Inizia ad Usare' : 'Avanti';
    if(skipBtn) skipBtn.textContent = (i===slides.length-1) ? 'Chiudi' : 'Salta';
    const prog = root.querySelector('[data-progress]');
    if(prog) prog.textContent = `${i+1}/${slides.length}`;
  }

  setSlide(0);

  nextBtn?.addEventListener('click', ()=>{
    if(i===slides.length-1){
      window.location.href = 'dashboard.html';
    } else {
      setSlide(i+1);
    }
  });

  skipBtn?.addEventListener('click', ()=>{
    window.location.href = 'dashboard.html';
  });

  dots.forEach((dot, idx)=>{
    dot.addEventListener('click', ()=> setSlide(idx));
  });

  let startX = null;
  root.addEventListener('touchstart', (e)=> startX = e.touches[0].clientX, {passive:true});
  root.addEventListener('touchend', (e)=>{
    if(startX==null) return;
    const dx = e.changedTouches[0].clientX - startX;
    if(Math.abs(dx) > 40){
      setSlide(i + (dx<0 ? 1 : -1));
    }
    startX = null;
  });
})();