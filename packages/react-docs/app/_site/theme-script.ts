// Plain strings (no "use client") so the server layout can inline the script
// and the client switches can share the keys.

export const THEME_KEY = "aeros-docs:theme";
export const DENSITY_KEY = "aeros-docs:density";

/**
 * Runs before first paint (inline, ahead of the shell markup) so a saved dark
 * theme never flashes light. Storage can throw (private mode, blocked): the
 * site then follows the OS for this visit.
 */
export const THEME_SCRIPT = `(function(){var d=document.documentElement;try{var t=localStorage.getItem("${THEME_KEY}");d.dataset.theme=t==="light"||t==="dark"||t==="system"?t:"system";var n=localStorage.getItem("${DENSITY_KEY}");if(n==="touch"||n==="pointer")d.dataset.density=n}catch(e){d.dataset.theme="system"}})()`;
