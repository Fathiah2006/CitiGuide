/* CitiGuide — auth & onboarding screens */
(function () {
  const { Icon, LogoMark, DeviceShell, Photo } = window;
  const h = React.createElement;
  const { useState } = React;

  /* logo lockup */
  function Logo({ size = 48, light = false, withText = false, sub }) {
    const fg = light ? '#fff' : 'var(--primary)';
    return h('div', { style: { display: 'flex', alignItems: 'center', gap: 13 } },
      h(LogoMark, light
        ? { size, pin: '#fff', north: 'var(--star)', south: 'var(--primary)' }
        : { size, pin: 'var(--primary)', north: 'var(--star)', south: '#fff' }),
      withText && h('div', null,
        h('div', { className: 't-display', style: { fontSize: size * .46, color: fg, lineHeight: 1 } },
          'Citi', h('span', { style: { color: light ? 'rgba(255,255,255,.6)' : 'var(--primary-300)' } }, 'Guide')),
        sub && h('div', { style: { fontSize: 12.5, color: light ? 'rgba(255,255,255,.6)' : 'var(--muted)', marginTop: 4, fontWeight: 500 } }, sub),
      ),
    );
  }

  /* faint topographic contour motif (echoes the in-app photo texture) */
  function Contours({ opacity = .07 }) {
    return h('svg', { width: '100%', height: '100%', viewBox: '0 0 344 718', preserveAspectRatio: 'xMidYMid slice',
      style: { position: 'absolute', inset: 0, opacity } },
      h('g', { fill: 'none', stroke: '#fff', strokeWidth: 1.1 },
        [0,1,2,3,4,5,6,7,8].map(i => h('path', { key: i,
          d: `M-30 ${70 + i * 78} C 70 ${30 + i * 78}, 150 ${130 + i * 78}, 240 ${80 + i * 78} S 380 ${40 + i * 78}, 380 ${90 + i * 78}` })),
      ),
    );
  }

  /* ── Splash ── */
  function Splash() {
    return h(DeviceShell, { statusTone: 'light', navTone: 'light', bg: 'var(--primary)' },
      // depth gradient + ambient light
      h('div', { style: { position: 'absolute', inset: 0, overflow: 'hidden', background: 'radial-gradient(125% 80% at 50% 30%, #114E73 0%, var(--primary) 46%, var(--primary-700) 100%)' } },
        h(Contours, { opacity: .07 }),
        // warm guiding-light glow behind the mark
        h('div', { style: { position: 'absolute', width: 320, height: 320, borderRadius: '50%', top: '30%', left: '50%', marginLeft: -160, marginTop: -160, background: 'radial-gradient(circle, rgba(232,162,61,.34), rgba(232,162,61,0) 62%)' } }),
      ),
      h('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', position: 'relative', gap: 30 } },
        h('div', { className: 'anim-up', style: { display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 26 } },
          // mark on a soft frosted coin
          h('div', { style: {
            width: 124, height: 124, borderRadius: '50%', position: 'relative',
            display: 'flex', alignItems: 'center', justifyContent: 'center',
            background: 'rgba(255,255,255,.06)', border: '1px solid rgba(255,255,255,.14)',
            boxShadow: '0 24px 60px rgba(3,18,30,.5), inset 0 1px 0 rgba(255,255,255,.18)',
          } },
            h('div', { style: { position: 'absolute', inset: 0, borderRadius: '50%', border: '1px solid rgba(255,255,255,.07)', transform: 'scale(1.34)', animation: 'splashRing 3.2s ease-in-out infinite' } }),
            h(LogoMark, { size: 76, pin: '#fff', north: 'var(--star)', south: 'var(--primary-300)', pivot: 'var(--primary)' }),
          ),
          h('div', { style: { textAlign: 'center' } },
            h('div', { className: 't-display', style: { fontSize: 40, color: '#fff', lineHeight: 1, letterSpacing: '-.025em' } },
              'Citi', h('span', { style: { color: 'rgba(255,255,255,.5)' } }, 'Guide')),
            h('div', { style: { fontSize: 14.5, color: 'rgba(255,255,255,.72)', marginTop: 12, fontWeight: 500, letterSpacing: '.01em' } }, 'Discover your city, like a local'),
          ),
        ),
      ),
      // slim indeterminate loading bar
      h('div', { style: { position: 'absolute', bottom: 52, left: 0, right: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 14 } },
        h('div', { style: { width: 120, height: 3, borderRadius: 3, background: 'rgba(255,255,255,.16)', overflow: 'hidden' } },
          h('div', { style: { width: '42%', height: '100%', borderRadius: 3, background: 'rgba(255,255,255,.9)', animation: 'splashBar 1.5s ease-in-out infinite' } })),
        h('div', { style: { fontSize: 10.5, letterSpacing: '.22em', textTransform: 'uppercase', color: 'rgba(255,255,255,.4)', fontWeight: 600 } }, 'Finding places near you'),
      ),
    );
  }

  /* shared text input */
  function Input({ icon, label, placeholder, type = 'text', value, onChange, trailing }) {
    return h('label', { style: { display: 'block', marginBottom: 16 } },
      label && h('span', { className: 'field-label' }, label),
      h('div', { className: 'field' },
        icon && h(Icon, { name: icon, size: 19, color: 'var(--muted)' }),
        h('input', { type, placeholder, value, onChange: e => onChange && onChange(e.target.value) }),
        trailing,
      ),
    );
  }

  function PasswordInput({ label = 'Password', value, onChange, placeholder = '••••••••' }) {
    const [show, setShow] = useState(false);
    return h(Input, {
      icon: 'lock', label, placeholder, value, onChange, type: show ? 'text' : 'password',
      trailing: h('button', { onClick: () => setShow(s => !s), tabIndex: -1, style: { color: 'var(--muted)', display: 'flex' } },
        h(Icon, { name: show ? 'eyeOff' : 'eye', size: 19 })),
    });
  }

  function AuthScaffold({ children, top }) {
    return h('div', { className: 'cg-scroll', style: { padding: '0 24px' } },
      h('div', { style: { paddingTop: 64 } }, top),
      children,
      h('div', { style: { height: 30 } }),
    );
  }

  function GoogleBtn({ label }) {
    return h('button', { className: 'btn btn-outline' },
      h('svg', { width: 18, height: 18, viewBox: '0 0 18 18' },
        h('path', { fill: '#4285F4', d: 'M17.6 9.2c0-.6-.1-1.2-.2-1.8H9v3.5h4.8a4.1 4.1 0 0 1-1.8 2.7v2.2h2.9c1.7-1.6 2.7-3.9 2.7-6.6z' }),
        h('path', { fill: '#34A853', d: 'M9 18c2.4 0 4.5-.8 6-2.2l-2.9-2.2c-.8.5-1.8.9-3.1.9-2.4 0-4.4-1.6-5.1-3.8H.9v2.3A9 9 0 0 0 9 18z' }),
        h('path', { fill: '#FBBC05', d: 'M3.9 10.7a5.4 5.4 0 0 1 0-3.4V5H.9a9 9 0 0 0 0 8l3-2.3z' }),
        h('path', { fill: '#EA4335', d: 'M9 3.6c1.3 0 2.5.5 3.4 1.3l2.6-2.6A9 9 0 0 0 .9 5l3 2.3C4.6 5.2 6.6 3.6 9 3.6z' }),
      ), label);
  }

  /* ── Login ── */
  function Login({ onLogin, onSignup, onForgot }) {
    const [email, setEmail] = useState('amara.okonkwo@gmail.com');
    const [pw, setPw] = useState('citiguide');
    return h(DeviceShell, { statusTone: 'dark' },
      h(AuthScaffold, {
        top: h('div', null,
          h(Logo, { size: 48 }),
          h('div', { className: 't-display', style: { fontSize: 30, marginTop: 28 } }, 'Welcome back'),
          h('div', { style: { fontSize: 15, color: 'var(--muted)', marginTop: 6, marginBottom: 30 } }, 'Log in to pick up where you left off.'),
        ),
      },
        h(Input, { icon: 'mail', label: 'Email', placeholder: 'you@email.com', value: email, onChange: setEmail, type: 'email' }),
        h(PasswordInput, { value: pw, onChange: setPw }),
        h('button', { onClick: onForgot, style: { display: 'block', marginLeft: 'auto', marginTop: -6, marginBottom: 22, fontSize: 13.5, fontWeight: 700, color: 'var(--primary)' } }, 'Forgot password?'),
        h('button', { className: 'btn btn-primary', onClick: onLogin }, 'Log in'),
        h('div', { style: { display: 'flex', alignItems: 'center', gap: 14, margin: '22px 0' } },
          h('div', { className: 'hr', style: { flex: 1 } }), h('span', { style: { fontSize: 12.5, color: 'var(--muted-2)', fontWeight: 600 } }, 'OR'), h('div', { className: 'hr', style: { flex: 1 } })),
        h(GoogleBtn, { label: 'Continue with Google' }),
        h('div', { style: { textAlign: 'center', marginTop: 26, fontSize: 14.5, color: 'var(--muted)' } },
          'New to CitiGuide? ',
          h('button', { onClick: onSignup, style: { fontWeight: 700, color: 'var(--primary)' } }, 'Create account')),
      ),
    );
  }

  /* ── Signup ── */
  function Signup({ onCreate, onLogin }) {
    const [agree, setAgree] = useState(true);
    return h(DeviceShell, { statusTone: 'dark' },
      h(AuthScaffold, {
        top: h('div', null,
          h(Logo, { size: 48 }),
          h('div', { className: 't-display', style: { fontSize: 30, marginTop: 28 } }, 'Create account'),
          h('div', { style: { fontSize: 15, color: 'var(--muted)', marginTop: 6, marginBottom: 30 } }, 'Save favourites and review the places you love.'),
        ),
      },
        h(Input, { icon: 'user', label: 'Full name', placeholder: 'Amara Okonkwo', value: 'Amara Okonkwo' }),
        h(Input, { icon: 'mail', label: 'Email', placeholder: 'you@email.com', value: 'amara.okonkwo@gmail.com', type: 'email' }),
        h(PasswordInput, { label: 'Create password', value: 'citiguide', placeholder: 'At least 8 characters' }),
        h('button', { onClick: () => setAgree(a => !a), style: { display: 'flex', alignItems: 'flex-start', gap: 11, margin: '4px 0 22px', textAlign: 'left' } },
          h('div', { style: { width: 22, height: 22, borderRadius: 7, flexShrink: 0, marginTop: 1, border: agree ? 'none' : '1.5px solid var(--line)', background: agree ? 'var(--primary)' : '#fff', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#fff' } }, agree && h(Icon, { name: 'check', size: 15, stroke: 2.6 })),
          h('span', { style: { fontSize: 13, color: 'var(--muted)', lineHeight: 1.5 } }, 'I agree to the ', h('span', { style: { color: 'var(--primary)', fontWeight: 700 } }, 'Terms'), ' and ', h('span', { style: { color: 'var(--primary)', fontWeight: 700 } }, 'Privacy Policy'), '.')),
        h('button', { className: 'btn btn-primary', onClick: onCreate }, 'Create account'),
        h('div', { style: { textAlign: 'center', marginTop: 24, fontSize: 14.5, color: 'var(--muted)' } },
          'Already have an account? ',
          h('button', { onClick: onLogin, style: { fontWeight: 700, color: 'var(--primary)' } }, 'Log in')),
      ),
    );
  }

  /* ── Forgot password (+ sent state) ── */
  function Forgot({ onBack, sent = false, onSend }) {
    if (sent) {
      return h(DeviceShell, { statusTone: 'dark' },
        h(window.TopBar, { onBack, transparent: true }),
        h('div', { style: { flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', textAlign: 'center', padding: '0 36px', gap: 8 } },
          h('div', { style: { width: 80, height: 80, borderRadius: 26, background: 'var(--primary-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)', marginBottom: 14 } }, h(Icon, { name: 'mail', size: 36 })),
          h('div', { className: 't-display', style: { fontSize: 26 } }, 'Check your inbox'),
          h('div', { style: { fontSize: 15, color: 'var(--muted)', lineHeight: 1.55, maxWidth: 280, marginTop: 4 } }, 'We’ve sent a password-reset link to ', h('b', { style: { color: 'var(--ink)' } }, 'amara.okonkwo@gmail.com'), '. It expires in 30 minutes.'),
          h('div', { style: { width: '100%', maxWidth: 260, marginTop: 26 } }, h('button', { className: 'btn btn-primary', onClick: onBack }, 'Back to log in')),
          h('button', { style: { marginTop: 14, fontSize: 14, color: 'var(--muted)', fontWeight: 600 } }, 'Didn’t get it? Resend'),
        ),
      );
    }
    return h(DeviceShell, { statusTone: 'dark' },
      h(window.TopBar, { onBack, transparent: true }),
      h(AuthScaffold, {
        top: h('div', null,
          h('div', { style: { width: 56, height: 56, borderRadius: 18, background: 'var(--primary-tint)', display: 'flex', alignItems: 'center', justifyContent: 'center', color: 'var(--primary)' } }, h(Icon, { name: 'lock', size: 28 })),
          h('div', { className: 't-display', style: { fontSize: 28, marginTop: 24 } }, 'Reset password'),
          h('div', { style: { fontSize: 15, color: 'var(--muted)', marginTop: 6, marginBottom: 28, lineHeight: 1.5 } }, 'Enter your email and we’ll send you a link to reset your password.'),
        ),
      },
        h(Input, { icon: 'mail', label: 'Email', placeholder: 'you@email.com', value: 'amara.okonkwo@gmail.com', type: 'email' }),
        h('button', { className: 'btn btn-primary', onClick: onSend, style: { marginTop: 6 } }, 'Send reset link'),
      ),
    );
  }

  Object.assign(window, { Splash, Login, Signup, Forgot, Logo, Input, PasswordInput });
})();
