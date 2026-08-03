import React, { useState } from 'react';
import {
  ActiveTab,
  Region,
  KPIStats,
  MarketSummary,
  LaneException,
  PlannedAdjustment,
  CustomerRateLane,
  DatasetItem,
  ValidationIssue
} from './types';
import {
  initialKPIStats,
  initialMarkets,
  initialLaneExceptions,
  initialPlannedAdjustments,
  initialCustomerLanes,
  initialDatasets,
  initialValidationIssues
} from './data/initialData';

import { TopNavBar } from './components/TopNavBar';
import { Sidebar } from './components/Sidebar';
import { TargetControlTower } from './components/TargetControlTower';
import { RateDirectory } from './components/RateDirectory';
import { DataManagement } from './components/DataManagement';

import { AdjustLaneModal } from './components/modals/AdjustLaneModal';
import { MapManualModal } from './components/modals/MapManualModal';
import { ScheduleAdjustmentModal } from './components/modals/ScheduleAdjustmentModal';
import { SettingsModal } from './components/modals/SettingsModal';
import { ReportsModal } from './components/modals/ReportsModal';

export default function App() {
  const [activeTab, setActiveTab] = useState<ActiveTab>('target_control_tower');
  const [selectedRegion, setSelectedRegion] = useState<Region>('NW');
  const [searchQuery, setSearchQuery] = useState<string>('');
  const [teamContext, setTeamContext] = useState<'Pricing Team' | 'Operations'>('Pricing Team');

  // Application Data States
  const [kpis] = useState<KPIStats>(initialKPIStats);
  const [markets, setMarkets] = useState<MarketSummary[]>(initialMarkets);
  const [laneExceptions, setLaneExceptions] = useState<LaneException[]>(initialLaneExceptions);
  const [plannedAdjustments, setPlannedAdjustments] = useState<PlannedAdjustment[]>(initialPlannedAdjustments);
  const [customerLanes, setCustomerLanes] = useState<CustomerRateLane[]>(initialCustomerLanes);
  const [datasets, setDatasets] = useState<DatasetItem[]>(initialDatasets);
  const [validationIssues, setValidationIssues] = useState<ValidationIssue[]>(initialValidationIssues);

  // Modal States
  const [adjustItem, setAdjustItem] = useState<LaneException | MarketSummary | CustomerRateLane | null>(null);
  const [mapIssue, setMapIssue] = useState<ValidationIssue | null>(null);
  const [showScheduleModal, setShowScheduleModal] = useState<boolean>(false);
  const [showSettingsModal, setShowSettingsModal] = useState<boolean>(false);
  const [showReportsModal, setShowReportsModal] = useState<boolean>(false);

  // Export CSV Helper
  const handleExportCSV = (filename: string, rows: Record<string, unknown>[]) => {
    if (!rows.length) return;
    const headers = Object.keys(rows[0]).join(',');
    const csvContent =
      'data:text/csv;charset=utf-8,' +
      [headers, ...rows.map((r) => Object.values(r).map((v) => `"${v}"`).join(','))].join('\n');
    const encodedUri = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encodedUri);
    link.setAttribute('download', filename);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const handleExportTargets = () => {
    const exportData = customerLanes.map((l) => ({
      LaneID: l.laneId,
      Customer: l.customerName,
      Origin: `${l.originCity}, ${l.originState}`,
      Destination: `${l.destinationCity}, ${l.destinationState}`,
      BaseRate: l.baseRate,
      Equipment: l.equipment,
      CarrierTarget: l.carrierTargetMatch.targetAmount,
      MatchPercent: l.carrierTargetMatch.matchPercent
    }));
    handleExportCSV('carrier_targets_export.csv', exportData);
  };

  const handleSaveAdjustment = ({
    id,
    target,
    changePercent,
    notes,
    excludeKeyAccounts
  }: {
    id: string;
    target: number;
    changePercent: number;
    notes: string;
    excludeKeyAccounts?: boolean;
  }) => {
    let adjustedItemTitle = 'Lane Adjustment';

    // Update lane exception if matching
    setLaneExceptions((prev) =>
      prev.map((exc) => {
        if (exc.id === id) {
          adjustedItemTitle = `${exc.origin} → ${exc.destination}`;
          if (exc.isKeyAccount && excludeKeyAccounts) {
            // Key volume account target adjustment excluded to preserve lower contracted rate
            return {
              ...exc,
              adjustmentStatus: 'Adjusted',
              adjustedNotes: `${notes} [Key Volume Account Excluded - Locked Contract Rate $${exc.currentTarget} Preserved]`
            };
          }
          const newVar = Math.round(exc.avgActual - target);
          const newVarPct = Math.round((newVar / target) * 1000) / 10;
          return {
            ...exc,
            currentTarget: target,
            varDollars: newVar,
            varPercent: newVarPct,
            adjustmentStatus: 'Adjusted',
            lastAdjustedTarget: target,
            adjustedDate: new Date().toLocaleDateString('en-US'),
            adjustedNotes: notes
          };
        }
        return exc;
      })
    );

    // Update market if matching
    const matchingMarket = markets.find((m) => m.id === id);
    if (matchingMarket) {
      adjustedItemTitle = `${matchingMarket.name} Market`;
      setLaneExceptions((prev) =>
        prev.map((exc) => {
          if (exc.market === matchingMarket.region) {
            if (exc.isKeyAccount && excludeKeyAccounts) {
              // Bypassed key contracted account to preserve lower 1-year contract rate
              return {
                ...exc,
                adjustedNotes: `${notes} [Bypassed for Key Volume Account - Contract Rate $${exc.currentTarget} Locked]`
              };
            }
            const newVar = Math.round(exc.avgActual - target);
            const newVarPct = Math.round((newVar / target) * 1000) / 10;
            return {
              ...exc,
              currentTarget: target,
              varDollars: newVar,
              varPercent: newVarPct,
              adjustmentStatus: 'Adjusted',
              lastAdjustedTarget: target,
              adjustedDate: new Date().toLocaleDateString('en-US'),
              adjustedNotes: notes
            };
          }
          return exc;
        })
      );
    }

    setMarkets((prev) =>
      prev.map((m) => {
        if (m.id === id) {
          const newVar = Math.round(m.avgActual - target);
          const newVarPct = Math.round((newVar / target) * 1000) / 10;
          return {
            ...m,
            avgTarget: target,
            varianceDollars: newVar,
            variancePercent: newVarPct
          };
        }
        return m;
      })
    );

    // Update customer lane if matching
    setCustomerLanes((prev) =>
      prev.map((lane) => {
        if (lane.id === id) {
          adjustedItemTitle = `${lane.customerName}: ${lane.originCity} → ${lane.destinationCity}`;
          return {
            ...lane,
            baseRate: target,
            totalBilling: Math.round((target * (1 + lane.fuelSurchargePercent / 100)) * 100) / 100
          };
        }
        return lane;
      })
    );

    // Also record planned adjustment
    setPlannedAdjustments((prev) => [
      {
        id: `adj-${Date.now()}`,
        type: 'Pricing Adjustment',
        title: `${adjustedItemTitle} (${changePercent >= 0 ? '+' : ''}${changePercent}%)`,
        changePercent,
        status: 'Active',
        effectiveDate: new Date().toLocaleDateString('en-US'),
        notes: notes || 'Target rate adjustment submitted by pricing analyst.'
      },
      ...prev
    ]);
  };

  const handleResolveMapIssue = (issueId: string, mappedValue: string) => {
    setValidationIssues((prev) =>
      prev.map((iss) => (iss.id === issueId ? { ...iss, resolved: true, suggestedValue: mappedValue } : iss))
    );
  };

  const handleAddPlannedAdjustment = (adj: PlannedAdjustment) => {
    setPlannedAdjustments((prev) => [adj, ...prev]);
  };

  const handleCommitDataChanges = () => {
    // Commit staged data updates into active rate lanes & control tower exceptions
    const newLane1: CustomerRateLane = {
      id: `lane-stg-${Date.now()}-1`,
      laneId: `OAK-SAC-${Math.floor(100 + Math.random() * 899)}`,
      originCity: 'Oakland',
      originState: 'CA',
      destinationCity: 'Sacramento',
      destinationState: 'CA',
      rawOrigin: 'Oakland, CA (OICT SSA Terminal)',
      rawDestination: 'Sacramento, CA (Distribution Hub)',
      baseRate: 720,
      equipment: "40' Dry Van",
      serviceType: 'Regional Drayage',
      miles: 88,
      status: 'AWARDED',
      activeState: 'Active',
      effectiveDate: new Date().toISOString().split('T')[0],
      expirationDate: '2027-06-30',
      reviewDate: '2027-05-15',
      customerName: 'Amazon Logistics, Inc.',
      fuelSurchargePercent: 14.0,
      fuelAmount: 100.8,
      totalBilling: 820.8,
      accessorials: [
        { id: `acc-${Date.now()}-1`, name: 'Chassis Split', rate: 75, applicability: 'Per Occurrence', effectiveDate: '2026-07-01' }
      ],
      carrierTargetMatch: {
        targetAmount: 680,
        matchPercent: 96,
        nearestLane: 'Oakland → Sacramento Direct'
      },
      rateHistory: [
        { amount: 720, effectiveRange: `Effective: ${new Date().toLocaleDateString()} - 06/30/2027`, status: 'Current' }
      ],
      recommendedCarriers: [
        {
          id: `carr-${Date.now()}`,
          name: 'Pacific Freight Lines',
          rank: 1,
          reliability: 99.1,
          serviceArea: 'Northern CA',
          notes: 'High performance regional fleet',
          statusColor: '#178A68'
        }
      ]
    };

    const newLane2: CustomerRateLane = {
      id: `lane-stg-${Date.now()}-2`,
      laneId: `LAX-PHX-${Math.floor(100 + Math.random() * 899)}`,
      originCity: 'Los Angeles',
      originState: 'CA',
      destinationCity: 'Phoenix',
      destinationState: 'AZ',
      rawOrigin: 'Los Angeles Port / LAX',
      rawDestination: 'Phoenix Metro Fulfillment Center',
      baseRate: 1450,
      equipment: "53' Dry Van",
      serviceType: 'Interstate Freight',
      miles: 372,
      status: 'AWARDED',
      activeState: 'Active',
      effectiveDate: new Date().toISOString().split('T')[0],
      expirationDate: '2027-06-30',
      reviewDate: '2027-05-15',
      customerName: 'Walmart Logistics',
      fuelSurchargePercent: 16.0,
      fuelAmount: 232,
      totalBilling: 1682,
      accessorials: [],
      carrierTargetMatch: {
        targetAmount: 1380,
        matchPercent: 95,
        nearestLane: 'LA → Phoenix Direct Corridor'
      },
      rateHistory: [
        { amount: 1450, effectiveRange: `Effective: ${new Date().toLocaleDateString()} - 06/30/2027`, status: 'Current' }
      ],
      recommendedCarriers: [
        {
          id: `carr-${Date.now()}-2`,
          name: 'Southwest Express Fleet',
          rank: 1,
          reliability: 97.8,
          serviceArea: 'Southwest',
          notes: 'Dedicated desert lane capacity',
          statusColor: '#178A68'
        }
      ]
    };

    setCustomerLanes((prev) => [newLane1, newLane2, ...prev]);

    // Also add to lane exceptions in Control Tower
    const newExc1: LaneException = {
      id: `exc-${Date.now()}-1`,
      origin: 'Oakland, CA',
      destination: 'Sacramento, CA',
      market: 'NW',
      loads: 48,
      currentTarget: 680,
      avgActual: 720,
      varDollars: 40,
      varPercent: 5.8,
      confidence: 'High',
      impact: 'Medium',
      adjustmentStatus: 'Pending Approval'
    };

    const newExc2: LaneException = {
      id: `exc-${Date.now()}-2`,
      origin: 'Los Angeles, CA',
      destination: 'Phoenix, AZ',
      market: 'SW',
      loads: 62,
      currentTarget: 1380,
      avgActual: 1450,
      varDollars: 70,
      varPercent: 5.1,
      confidence: 'High',
      impact: 'High',
      adjustmentStatus: 'Pending Approval'
    };

    setLaneExceptions((prev) => [newExc1, newExc2, ...prev]);

    // Update datasets state
    setDatasets((prev) =>
      prev.map((ds) => ({
        ...ds,
        recordsCount: ds.recordsCount + 2,
        lastUpload: `Committed ${new Date().toLocaleDateString('en-US')} by Pricing Ops`,
        status: 'Active / Updated'
      }))
    );

    setValidationIssues((prev) => prev.map((i) => ({ ...i, resolved: true })));
    alert('Validation staging preview committed successfully! Staged rate lanes added to Master Rate Directory and Control Tower.');
  };

  const handleDiscardDataChanges = () => {
    // Staging discarded notification handled with clean in-app toast feedback inside DataManagement
  };

  const handleUploadFileSimulated = (filename: string) => {
    setDatasets((prev) =>
      prev.map((ds, idx) =>
        idx === 0
          ? {
              ...ds,
              lastUpload: `Just now (${filename}) by Sarah M.`,
              recordsCount: ds.recordsCount + 450
            }
          : ds
      )
    );
  };

  const handleAddCustomer = (cust: { name: string; code: string }) => {
    const newLane: CustomerRateLane = {
      id: `lane-cust-${Date.now()}`,
      laneId: `${cust.code || 'CUST'}-001`,
      customerName: cust.name,
      originCity: 'Oakland',
      originState: 'CA',
      rawOrigin: 'OICT SSA Terminal Oakland',
      destinationCity: 'Stockton',
      destinationState: 'CA',
      rawDestination: 'Amazon TCY2 Stockton',
      baseRate: 780,
      fuelSurchargePercent: 14.5,
      fuelAmount: 113.1,
      totalBilling: 893.1,
      effectiveDate: '2026-07-01',
      expirationDate: '2027-06-30',
      reviewDate: '2026-10-01',
      status: 'AWARDED',
      activeState: 'Active',
      miles: 78,
      equipment: '53ft Dry Van',
      serviceType: 'Import Drayage',
      accessorials: [{ id: 'acc-1', name: 'Chassis Split', rate: 125, applicability: 'Per Container', effectiveDate: '2026-07-01' }],
      recommendedCarriers: [
        { id: 'carr-1', name: 'FLAT-LINE XPRESS LLC', rank: 1, reliability: 98, statusColor: '#178A68', serviceArea: 'NW Drayage', notes: 'Preferred Drayage Carrier' }
      ],
      carrierTargetMatch: { matchPercent: 100, targetAmount: 780, nearestLane: 'Oakland, CA -> Stockton, CA' },
      rateHistory: [{ amount: 780, effectiveRange: '2026-07-01 to Present', status: 'Current' }]
    };
    setCustomerLanes((prev) => [newLane, ...prev]);
  };

  const handleAddLane = (newLane: CustomerRateLane) => {
    setCustomerLanes((prev) => [newLane, ...prev]);
  };

  return (
    <div className="min-h-screen bg-[#F4F7FA] font-['Inter',sans-serif] text-[#14213D] flex flex-col relative">
      {/* Top Header Navigation */}
      <TopNavBar
        activeTab={activeTab}
        setActiveTab={setActiveTab}
        searchQuery={searchQuery}
        setSearchQuery={setSearchQuery}
        teamContext={teamContext}
        setTeamContext={setTeamContext}
        onOpenSettings={() => setShowSettingsModal(true)}
      />

      {/* Primary Layout Area */}
      <div className="flex flex-1 overflow-hidden relative">
        {/* Persistent Operational Sidebar */}
        <Sidebar
          activeTab={activeTab}
          setActiveTab={setActiveTab}
          onOpenReports={() => setShowReportsModal(true)}
          onOpenSettings={() => setShowSettingsModal(true)}
        />

        {/* Main Workspace Viewport */}
        <main className="flex-1 overflow-y-auto min-h-[calc(100vh-64px)] p-4 sm:p-6">
          {activeTab === 'target_control_tower' && (
            <TargetControlTower
              kpis={kpis}
              markets={markets}
              laneExceptions={laneExceptions}
              plannedAdjustments={plannedAdjustments}
              selectedRegion={selectedRegion}
              setSelectedRegion={setSelectedRegion}
              onAdjustLane={(exc) => setAdjustItem(exc)}
              onAdjustMarket={(mkt) => setAdjustItem(mkt)}
              onScheduleNewChange={() => setShowScheduleModal(true)}
              onUploadData={() => setActiveTab('data_management')}
              onExportTargets={handleExportTargets}
              searchQuery={searchQuery}
              teamContext={teamContext}
            />
          )}

          {activeTab === 'rate_directory' && (
            <RateDirectory
              lanes={customerLanes}
              onEditLane={(lane) => setAdjustItem(lane)}
              onUploadData={() => setActiveTab('data_management')}
              onExport={handleExportTargets}
              searchQuery={searchQuery}
              onAddCustomer={handleAddCustomer}
              onAddLane={handleAddLane}
              teamContext={teamContext}
            />
          )}

          {activeTab === 'data_management' && (
            <DataManagement
              datasets={datasets}
              validationIssues={validationIssues}
              onOpenMapManual={(issue) => setMapIssue(issue)}
              onCommitChanges={handleCommitDataChanges}
              onDiscardChanges={handleDiscardDataChanges}
              onUploadFileSimulated={handleUploadFileSimulated}
              customersList={Array.from(new Set(customerLanes.map((l) => l.customerName)))}
              onAddCustomer={handleAddCustomer}
            />
          )}
        </main>
      </div>

      {/* Modals */}
      <AdjustLaneModal
        item={adjustItem}
        onClose={() => setAdjustItem(null)}
        onSave={handleSaveAdjustment}
      />

      <MapManualModal
        issue={mapIssue}
        onClose={() => setMapIssue(null)}
        onResolve={handleResolveMapIssue}
      />

      <ScheduleAdjustmentModal
        isOpen={showScheduleModal}
        onClose={() => setShowScheduleModal(false)}
        onAddPlannedAdjustment={handleAddPlannedAdjustment}
      />

      <SettingsModal
        isOpen={showSettingsModal}
        onClose={() => setShowSettingsModal(false)}
      />

      <ReportsModal
        isOpen={showReportsModal}
        onClose={() => setShowReportsModal(false)}
      />
    </div>
  );
}
