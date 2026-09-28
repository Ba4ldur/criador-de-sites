// Contatos centralizados — altere aqui.
const CONFIG = {
  whatsapp: '5586988472024',
  whatsappMsg: 'Olá! Vim pelo site e gostaria de solicitar um orçamento.',
  instagram: 'https://www.instagram.com/', // PENDENTE: colocar o @ correto
};

// Links de WhatsApp e Instagram
document.querySelectorAll('.js-whats').forEach((a) => {
  const msg = a.dataset.msg || CONFIG.whatsappMsg;
  a.href = `https://wa.me/${CONFIG.whatsapp}?text=${encodeURIComponent(msg)}`;
  a.target = '_blank';
  a.rel = 'noopener';
});
document.querySelectorAll('.js-insta').forEach((a) => {
  a.href = CONFIG.instagram;
  a.target = '_blank';
  a.rel = 'noopener';
});

document.getElementById('ano').textContent = new Date().getFullYear();

// Topo com fundo ao rolar
const topo = document.getElementById('topo');
const onScroll = () => topo.classList.toggle('is-scrolled', window.scrollY > 40);
onScroll();
window.addEventListener('scroll', onScroll, { passive: true });

// Menu mobile
const burger = document.getElementById('burger');
const nav = document.getElementById('nav');
const setMenu = (open) => {
  nav.classList.toggle('is-open', open);
  burger.setAttribute('aria-expanded', open);
  burger.setAttribute('aria-label', open ? 'Fechar menu' : 'Abrir menu');
  document.body.style.overflow = open ? 'hidden' : '';
};
burger.addEventListener('click', () => setMenu(!nav.classList.contains('is-open')));
nav.querySelectorAll('a').forEach((a) => a.addEventListener('click', () => setMenu(false)));
document.addEventListener('keydown', (e) => e.key === 'Escape' && setMenu(false));

// Link ativo conforme a seção visível
const links = [...nav.querySelectorAll('a[href^="#"]:not(.btn)')];
const secoes = links.map((a) => document.querySelector(a.getAttribute('href'))).filter(Boolean);
const obsNav = new IntersectionObserver((entries) => {
  entries.forEach((en) => {
    if (!en.isIntersecting) return;
    links.forEach((a) => a.classList.toggle('is-active', a.getAttribute('href') === `#${en.target.id}`));
  });
}, { rootMargin: '-45% 0px -50% 0px' });
secoes.forEach((s) => obsNav.observe(s));

// Carrossel de projetos: setas só aparecem quando há o que rolar
const track = document.getElementById('track');
const carousel = track.closest('.carousel');
const checkOverflow = () => carousel.classList.toggle('has-overflow', track.scrollWidth > track.clientWidth + 1);
checkOverflow();
new ResizeObserver(checkOverflow).observe(track);
document.querySelectorAll('.carousel__nav').forEach((btn) => {
  btn.addEventListener('click', () => {
    const card = track.firstElementChild.getBoundingClientRect().width + 16;
    track.scrollBy({ left: card * Number(btn.dataset.dir), behavior: 'smooth' });
  });
});

// Comparador antes/depois
const compare = document.getElementById('compare');
compare.querySelector('.compare__range').addEventListener('input', (e) => {
  compare.style.setProperty('--pos', `${e.target.value}%`);
});

// Animação de entrada
const revealEls = document.querySelectorAll('.servico, .proj, .sobre__txt, .stat, .compare, .insta__grid a, .contato__info, .contato__mapa, .sec__head');
revealEls.forEach((el) => el.classList.add('reveal'));
const obsReveal = new IntersectionObserver((entries) => {
  entries.forEach((en) => {
    if (en.isIntersecting) {
      en.target.classList.add('is-in');
      obsReveal.unobserve(en.target);
    }
  });
}, { threshold: 0.15 });
revealEls.forEach((el) => obsReveal.observe(el));

// Botão flutuante some quando o contato (com os mesmos botões) está na tela
const whatsFloat = document.querySelector('.whats-float');
new IntersectionObserver(([en]) => {
  whatsFloat.classList.toggle('is-hidden', en.isIntersecting);
}, { threshold: 0.2 }).observe(document.getElementById('contato'));
