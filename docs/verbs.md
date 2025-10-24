[H[2J[3J
🩸  SEVERFORGE VERBS REFERENCE
────────────────────────────────────────────────────────────────

Version: v1.0.2       Authors: Amish × Pisces
Last Updated: 2025-10-24

────────────────────────────────────────────────────────────────

  🧰  Core Verbs

                │ Command                                       │ Typical Use              
────────────  │ ───────────────────────────────────────────── │ ───────────────────────
sf_banner       │ Display the Severforge banner.                │ sf banner                
sf_status       │ Display integrity, uptime, hash verification. │ After updates            
sf_sanitize     │ Strip temp files and cached logs.             │ Between bounties         
sf_react        │ Trigger forge animation flare.                │ Visual test              
sf_watch        │ Run forge watcher for events.                 │ Background mode          
sf_logview      │ Pretty-print historical logs.                 │ Review sessions          

  ⚙️  Recon & Automation Verbs

                │ Command                                       │ Typical Use              
────────────  │ ───────────────────────────────────────────── │ ───────────────────────
sf_recon        │ Launch Recon Suite (nmap, httpx, nuclei).     │ sf recon target.com      
sf_scan         │ Quick vulnerability sweep.                    │ Small-scope checks       
sf_clone        │ Duplicate environment into clean clone.       │ Multi-collab / training  

  🧭  sf pipeline_full — Automated Teaching + Recon Flow
────────────────────────────────────────────────────────────────

Usage:     sf pipeline_full [--auto] [TARGET]
Purpose:   Full chained recon run with auto-permission prompts.
Sequence:  amass → httpx → nuclei → pipeline manifest
Safety:    Safe by default; push only when confirmed.
Examples:
  sf pipeline_full
  sf pipeline_full --auto example.com

💫 End of reference — forged knowledge.

