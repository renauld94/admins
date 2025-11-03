(function(){
  const badge = document.getElementById('dev-build-info');
  if(!badge) return;

  const devEnabled = location.search.includes('dev') || localStorage.getItem('devmode') === '1';
  // keep badge hidden unless dev mode explicitly enabled
  badge.style.display = 'none';
  badge.classList.add('hidden-by-default');

  function showBadge(text){
    badge.textContent = text;
    badge.style.display = 'block';
  }

  // Try to fetch build-info.json first
  fetch('/build-info.json', {cache: 'no-store'}).then(res=>{
    if(!res.ok) throw new Error('no build-info');
    return res.json();
  }).then(j=>{
    const txt = `Live: ${j.build_time_utc || j.build_time || 'unknown'} • v:${j.version || j.commit || 'unknown'} • ${j.branch?('branch:'+j.branch):''}`;
    if(devEnabled) showBadge(txt);
    else badge.setAttribute('data-build', txt);
  }).catch(()=>{
    // Fallback: HEAD request to index.html to get Last-Modified
    fetch(window.location.pathname, {method: 'HEAD', cache: 'no-store'}).then(r=>{
      const lm = r.headers.get('last-modified') || r.headers.get('date') || '';
      const txt = lm? `Last-modified: ${lm}` : 'Build info unavailable';
      if(devEnabled) showBadge(txt);
      else badge.setAttribute('data-build', txt);
    }).catch(()=>{
      badge.setAttribute('data-build','no build info');
    });
  });

  // Allow quick toggle with localStorage: press Shift+B to toggle devmode
  window.addEventListener('keydown', (e)=>{
    if(e.shiftKey && e.key === 'B'){
      const cur = localStorage.getItem('devmode') === '1';
      localStorage.setItem('devmode', cur? '0' : '1');
      location.reload();
    }
  });
})();
