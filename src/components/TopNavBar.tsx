import React, { useState } from 'react';
import { ActiveTab } from '../types';

interface TopNavBarProps {
  activeTab: ActiveTab;
  setActiveTab: (tab: ActiveTab) => void;
  searchQuery: string;
  setSearchQuery: (query: string) => void;
  teamContext: 'Pricing Team' | 'Operations';
  setTeamContext: (context: 'Pricing Team' | 'Operations') => void;
  onOpenSettings: () => void;
  onOpenReportIssue?: () => void;
  reportedCount?: number;
}

export const TopNavBar: React.FC<TopNavBarProps> = ({
  activeTab,
  setActiveTab,
  searchQuery,
  setSearchQuery,
  teamContext,
  setTeamContext,
  onOpenSettings,
  onOpenReportIssue,
  reportedCount = 0
}) => {
  const [showNotifications, setShowNotifications] = useState(false);

  const notifications = [
    ...(reportedCount > 0
      ? [{ id: 'nr1', title: `${reportedCount} Operations Issue(s) Dispatched to Pricing`, time: 'Just now', unread: true }]
      : []),
    { id: 'n1', title: 'Oakland Market variance high', time: '10 mins ago', unread: true },
    { id: 'n2', title: 'New load data imported for Week 27', time: '1 hour ago', unread: true },
    { id: 'n3', title: 'Rate adjustment for Chicago -> Atlanta approved', time: '3 hours ago', unread: false }
  ];

  return (
    <header className="bg-[#0B1930] text-white sticky top-0 z-50 border-b border-[#D8E1EB]">
      <div className="flex items-center h-16 w-full max-w-[1440px] mx-auto px-6 gap-4">
        {/* Brand Anchor */}
        <div 
          onClick={() => setActiveTab('target_control_tower')}
          className="font-bold text-xl tracking-tight text-white shrink-0 mr-4 cursor-pointer flex items-center gap-2 hover:opacity-90 transition-opacity"
        >
          <div className="w-7 h-7 bg-[#1769FF] rounded flex items-center justify-center text-white">
            <span className="material-symbols-outlined text-[18px]">local_shipping</span>
          </div>
          <span>Pricing Hub</span>
          <span className="hidden sm:inline text-xs font-normal text-[#7784a0] border-l border-[#7784a0]/30 pl-2 ml-1">
            Forrest Logistics
          </span>
        </div>

        {/* Navigation */}
        <nav className="hidden md:flex items-center h-full space-x-6 shrink-0">
          <button
            onClick={() => setActiveTab('target_control_tower')}
            className={`h-full flex items-center font-bold text-xs uppercase tracking-wider transition-colors duration-200 ${
              activeTab === 'target_control_tower'
                ? 'text-white border-b-2 border-[#1769FF] pb-0.5'
                : 'text-[#7784a0] hover:text-white'
            }`}
          >
            Target Control Tower
          </button>
          <button
            onClick={() => setActiveTab('rate_directory')}
            className={`h-full flex items-center font-bold text-xs uppercase tracking-wider transition-colors duration-200 ${
              activeTab === 'rate_directory'
                ? 'text-white border-b-2 border-[#1769FF] pb-0.5'
                : 'text-[#7784a0] hover:text-white'
            }`}
          >
            Rate Directory
          </button>

          {/* Data Management restricted for Operations View */}
          {teamContext !== 'Operations' ? (
            <button
              onClick={() => setActiveTab('data_management')}
              className={`h-full flex items-center font-bold text-xs uppercase tracking-wider transition-colors duration-200 ${
                activeTab === 'data_management'
                  ? 'text-white border-b-2 border-[#1769FF] pb-0.5'
                  : 'text-[#7784a0] hover:text-white'
              }`}
            >
              Data Management
            </button>
          ) : (
            <span
              className="h-full flex items-center font-bold text-xs uppercase tracking-wider text-[#475569] cursor-not-allowed opacity-60 flex items-center gap-1"
              title="Data Management is restricted in Operations View"
            >
              <span className="material-symbols-outlined text-xs">lock</span>
              <span>Data Management</span>
            </span>
          )}
        </nav>

        {/* Search Bar */}
        <div className="flex-grow max-w-xl mx-2 relative">
          <span className="material-symbols-outlined absolute left-3 top-1/2 -translate-y-1/2 text-[#7784a0] text-sm pointer-events-none">
            search
          </span>
          <input
            type="text"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="Search customer, origin, destination, port, ZIP, lane ID, target..."
            className="w-full bg-white/10 border border-white/10 rounded-lg py-1.5 pl-9 pr-3 text-white text-xs placeholder:text-[#7784a0] focus:outline-none focus:ring-1 focus:ring-[#1769FF] focus:border-[#1769FF] transition-all"
          />
          {searchQuery && (
            <button 
              onClick={() => setSearchQuery('')}
              className="absolute right-2.5 top-1/2 -translate-y-1/2 text-[#7784a0] hover:text-white text-xs"
            >
              ✕
            </button>
          )}
        </div>

        {/* Right Actions */}
        <div className="flex items-center gap-3 shrink-0 ml-auto">
          {/* Team Context Selector */}
          <div className="flex bg-[#0e1b32] border border-[#3a4760]/50 rounded-lg p-0.5">
            <button
              onClick={() => setTeamContext('Pricing Team')}
              className={`px-3 py-1 rounded text-xs font-semibold transition-all ${
                teamContext === 'Pricing Team'
                  ? 'bg-[#1769FF] text-white shadow-sm'
                  : 'text-[#7784a0] hover:text-white'
              }`}
            >
              Pricing Team
            </button>
            <button
              onClick={() => setTeamContext('Operations')}
              className={`px-3 py-1 rounded text-xs font-semibold transition-all ${
                teamContext === 'Operations'
                  ? 'bg-[#1769FF] text-white shadow-sm'
                  : 'text-[#7784a0] hover:text-white'
              }`}
            >
              Operations
            </button>
          </div>

          {/* Report Issue Button */}
          {onOpenReportIssue && (
            <button
              onClick={onOpenReportIssue}
              className={`px-3 py-1.5 rounded-lg text-xs font-bold transition-all flex items-center gap-1.5 shadow-xs ${
                teamContext === 'Operations'
                  ? 'bg-[#D58A16] hover:bg-[#B46E0E] text-white animate-pulse'
                  : 'bg-white/10 hover:bg-white/20 text-white'
              }`}
              title="Report an issue or target rate override request to Pricing Team"
            >
              <span className="material-symbols-outlined text-sm">flag</span>
              <span className="hidden sm:inline">Report Issue</span>
            </button>
          )}

          <div className="h-6 w-px bg-white/20 hidden sm:block"></div>

          {/* Notifications button & dropdown */}
          <div className="relative">
            <button
              onClick={() => setShowNotifications(!showNotifications)}
              className="relative text-[#7784a0] hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors"
              title="Notifications"
            >
              <span className="material-symbols-outlined text-[20px]">notifications</span>
              <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-[#1769FF]"></span>
            </button>

            {showNotifications && (
              <div className="absolute right-0 mt-2 w-80 bg-white text-[#14213D] rounded-xl shadow-2xl border border-[#D8E1EB] py-2 z-50 animate-in fade-in slide-in-from-top-2 duration-150">
                <div className="px-4 py-2 border-b border-[#D8E1EB] flex justify-between items-center">
                  <span className="font-bold text-xs uppercase tracking-wider text-[#0B1930]">Alerts & System Logs</span>
                  <span className="text-[10px] bg-[#EAF2FF] text-[#1769FF] px-2 py-0.5 rounded-full font-bold">2 New</span>
                </div>
                <div className="divide-y divide-[#D8E1EB]/60 max-h-64 overflow-y-auto">
                  {notifications.map((n) => (
                    <div key={n.id} className={`p-3 text-xs hover:bg-[#F4F7FA] cursor-pointer ${n.unread ? 'bg-[#EAF2FF]/30' : ''}`}>
                      <div className="font-semibold text-[#0B1930]">{n.title}</div>
                      <div className="text-[10px] text-[#45474d] mt-1">{n.time}</div>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>

          {/* Settings button */}
          <button
            onClick={onOpenSettings}
            className="text-[#7784a0] hover:text-white p-1.5 rounded-lg hover:bg-white/10 transition-colors"
            title="Settings"
          >
            <span className="material-symbols-outlined text-[20px]">settings</span>
          </button>

          {/* User Avatar */}
          <div className="flex items-center gap-2 pl-1 cursor-pointer">
            <div className="w-8 h-8 rounded-full bg-[#4F83B8] flex items-center justify-center text-xs font-bold border border-white/20 text-white shadow-sm">
              JD
            </div>
          </div>
        </div>
      </div>
    </header>
  );
};
