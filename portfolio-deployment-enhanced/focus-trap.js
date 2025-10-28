// Lightweight focus-trap utility
// Usage: const trap = createFocusTrap(container); trap.activate(); trap.deactivate();
(function(global){
  function createFocusTrap(container){
    const focusableSelectors = 'a[href], area[href], input:not([disabled]):not([type=hidden]), select:not([disabled]), textarea:not([disabled]), button:not([disabled]), iframe, [tabindex]:not([tabindex="-1"])';
    let handler = null;
    let previousActive = null;

    function getFocusable(){
      return Array.from(container.querySelectorAll(focusableSelectors)).filter(el => el.offsetParent !== null);
    }

    function keyHandler(e){
      if(e.key !== 'Tab') return;
      const focusable = getFocusable();
      if(!focusable.length) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];
      if(e.shiftKey){
        if(document.activeElement === first){
          e.preventDefault();
          last.focus();
        }
      } else {
        if(document.activeElement === last){
          e.preventDefault();
          first.focus();
        }
      }
    }

    return {
      activate(){
        previousActive = document.activeElement;
        handler = keyHandler;
        document.addEventListener('keydown', handler);
        const focusable = getFocusable();
        if(focusable.length) focusable[0].focus();
      },
      deactivate(){
        if(handler) document.removeEventListener('keydown', handler);
        handler = null;
        try{ if(previousActive && previousActive.focus) previousActive.focus(); }catch(e){}
        previousActive = null;
      }
    };
  }

  // export
  if(typeof module !== 'undefined' && module.exports){ module.exports = createFocusTrap; }
  else { global.createFocusTrap = createFocusTrap; }
})(window);
