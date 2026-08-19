// Comprehensive Realistic Indian Mock Data for SafeSenior Admin & Guardian Suite

export const mockStats = {
  activeSeniors: 4280,
  protectedGuardians: 6140,
  scamsInterceptedToday: 184,
  scamsInterceptedMonth: 5820,
  activeThreatLevel: 'MODERATE',
  highRiskAlerts: 12,
  systemHealth: '99.98%',
  avgResponseTimeMin: 2.4,
  quizzesCompleted: 14230,
  wearablesOnline: 3910
}

export const mockUsers = [
  {
    id: 'usr-101',
    name: 'Shanti Patel',
    age: 76,
    phone: '+91 98250 14820',
    email: 'shanti.patel38@gmail.com',
    location: 'Ahmedabad, Gujarat (Navrangpura)',
    riskScore: 24,
    status: 'Protected',
    device: 'Samsung Galaxy A15 (Knox Secured)',
    lastActive: '12 mins ago',
    guardians: [
      { name: 'Amit Patel', relation: 'Son', phone: '+91 98240 88219', role: 'Primary' },
      { name: 'Pooja Patel', relation: 'Daughter-in-law', phone: '+91 97250 33410', role: 'Secondary' }
    ],
    recentThreats: 1,
    spendingLimit: '₹25,000/day',
    geofenceStatus: 'Inside Home Safe Zone',
    avatar: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'usr-102',
    name: 'Ramesh Sharma',
    age: 82,
    phone: '+91 98110 59281',
    email: 'ramesh.sharma1944@outlook.com',
    location: 'New Delhi, NCR (Dwarka Sector 12)',
    riskScore: 88,
    status: 'High Alert',
    device: 'OnePlus Nord CE4',
    lastActive: '2 mins ago',
    guardians: [
      { name: 'Neha Sharma', relation: 'Daughter', phone: '+91 98100 12399', role: 'Primary' }
    ],
    recentThreats: 5,
    spendingLimit: '₹15,000/day',
    geofenceStatus: 'Outside Safe Zone (Unusual)',
    avatar: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'usr-103',
    name: 'Anandi Deshmukh',
    age: 74,
    phone: '+91 98201 44829',
    email: 'anandi.deshmukh@yahoo.in',
    location: 'Mumbai, Maharashtra (Dadar West)',
    riskScore: 42,
    status: 'Protected',
    device: 'Vivo V30e',
    lastActive: '1 hour ago',
    guardians: [
      { name: 'Rohan Deshmukh', relation: 'Son', phone: '+91 98200 77889', role: 'Primary' }
    ],
    recentThreats: 2,
    spendingLimit: '₹50,000/day',
    geofenceStatus: 'Inside Mumbai Safe Zone',
    avatar: 'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'usr-104',
    name: 'Harish Verma',
    age: 85,
    phone: '+91 98450 12890',
    email: 'harish.verma@rediffmail.com',
    location: 'Bengaluru, Karnataka (Jayanagar 4th Block)',
    riskScore: 94,
    status: 'Active Incident',
    device: 'Samsung Galaxy F15',
    lastActive: 'Just now',
    guardians: [
      { name: 'Vikram Verma', relation: 'Son', phone: '+91 98455 88211', role: 'Primary' },
      { name: 'Dr. Sneha Kulkarni', relation: 'Caregiver / Doctor', phone: '+91 98440 11223', role: 'Medical' }
    ],
    recentThreats: 8,
    spendingLimit: '₹10,000/day',
    geofenceStatus: 'Near Bank ATM (Unusual Hours)',
    avatar: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=150&auto=format&fit=crop&q=80'
  },
  {
    id: 'usr-105',
    name: 'K. Narayanaswamy',
    age: 79,
    phone: '+91 98401 77310',
    email: 'k.narayana1947@gmail.com',
    location: 'Chennai, Tamil Nadu (Mylapore)',
    riskScore: 31,
    status: 'Protected',
    device: 'Redmi Note 13',
    lastActive: '35 mins ago',
    guardians: [
      { name: 'Sundar Narayanan', relation: 'Son', phone: '+91 98400 99112', role: 'Primary' }
    ],
    recentThreats: 0,
    spendingLimit: '₹30,000/day',
    geofenceStatus: 'Inside Home Safe Zone',
    avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&auto=format&fit=crop&q=80'
  }
]

export const mockGuardians = [
  { id: 'g-1', name: 'Amit Patel', relation: 'Son', phone: '+91 98240 88219', user: 'Shanti Patel', status: 'Active' },
  { id: 'g-2', name: 'Neha Sharma', relation: 'Daughter', phone: '+91 98100 12399', user: 'Ramesh Sharma', status: 'Active' },
  { id: 'g-3', name: 'Rohan Deshmukh', relation: 'Son', phone: '+91 98200 77889', user: 'Anandi Deshmukh', status: 'Active' },
  { id: 'g-4', name: 'Vikram Verma', relation: 'Son', phone: '+91 98455 88211', user: 'Harish Verma', status: 'Active' },
  { id: 'g-5', name: 'Sundar Narayanan', relation: 'Son', phone: '+91 98400 99112', user: 'K. Narayanaswamy', status: 'Active' }
]

export const mockAlerts = [
  {
    id: 'alt-901',
    seniorId: 'usr-104',
    seniorName: 'Harish Verma',
    type: 'Digital Arrest & CBI Cyber Police Impersonation',
    channel: 'WhatsApp Video Call (Spoofed Police Uniform)',
    confidence: '98.4%',
    severity: 'Critical',
    timestamp: '10 minutes ago',
    status: 'Escalated to Guardian',
    summary: 'Scammer claimed Harish’s Aadhaar card was found in a money laundering parcel at Mumbai Customs. Demanded ₹3,50,000 RTGS to fake RBI clearance account under "Digital Arrest".',
    actionTaken: 'Video call auto-flagged, real-time warning delivered, son Vikram alerted, 1930 Cybercrime report drafted.'
  },
  {
    id: 'alt-902',
    seniorId: 'usr-102',
    seniorName: 'Ramesh Sharma',
    type: 'Electricity Bill Disconnection SMS (MSEDCL/BSES)',
    channel: 'SMS Text (+91 98765-43210)',
    confidence: '94.2%',
    severity: 'High',
    timestamp: '28 minutes ago',
    status: 'Investigating',
    summary: 'SMS claimed power supply will be cut off at 9:30 PM unless an APK file was installed to pay pending ₹18 bill.',
    actionTaken: 'SMS quarantined, malicious APK installation blocked, bank access shielded.'
  },
  {
    id: 'alt-903',
    seniorId: 'usr-103',
    seniorName: 'Anandi Deshmukh',
    type: 'SBI YONO KYC Expiry / PAN Card Phishing',
    channel: 'SMS / Web Link',
    confidence: '89.1%',
    severity: 'Medium',
    timestamp: '2 hours ago',
    status: 'Resolved',
    summary: 'SMS urged updating PAN details on fake sbi-yono-update-kyc.in domain to prevent netbanking block.',
    actionTaken: 'Domain blocked globally across Indian carrier relays, quiz module recommended.'
  },
  {
    id: 'alt-904',
    seniorId: 'usr-101',
    seniorName: 'Shanti Patel',
    type: 'UPI QR Code "Cashback / Refund" Trap',
    channel: 'WhatsApp Call & QR Image',
    confidence: '91.0%',
    severity: 'Medium',
    timestamp: '5 hours ago',
    status: 'Resolved',
    summary: 'Caller claimed ₹4,999 lottery cashback on PhonePe and requested scanning QR code and entering UPI PIN.',
    actionTaken: 'Transaction blocked, UPI PIN prompt neutralized, senior notified.'
  }
]

export const mockScamReports = [
  {
    id: 'rep-001',
    type: 'sms',
    sender: '+91 98210 99482',
    classification: 'high-risk',
    body_preview: 'Dear Customer, your SBI account will be blocked today. Please update PAN at sbi-pan-kyc-verify.co.in',
    timestamp: '2026-08-17 12:45'
  },
  {
    id: 'rep-002',
    type: 'call',
    sender: '+91 98450 01928',
    classification: 'high-risk',
    body_preview: 'CBI Mumbai Police Digital Arrest: Immediate ₹3,50,000 security deposit demanded via RTGS.',
    timestamp: '2026-08-17 11:20'
  },
  {
    id: 'rep-003',
    type: 'sms',
    sender: '+91 97110 33901',
    classification: 'high-risk',
    body_preview: 'Electricity power will be disconnected at 9:30 PM. Contact Electricity Officer at +91 9876543210 immediately.',
    timestamp: '2026-08-17 09:15'
  }
]

export const mockScamPatterns = [
  {
    id: 'pat-001',
    title: 'CBI / Mumbai Customs "Digital Arrest" Extortion',
    category: 'Police Impersonation',
    detectionCount: 2480,
    riskWeight: 'CRITICAL (9.8/10)',
    keywords: ['digital arrest', 'aadhaar linked to drugs', 'mumbai customs', 'cbi officer', 'rbi verification account', 'transfer rtgs'],
    rulesTriggered: 24,
    status: 'Active Enforced'
  },
  {
    id: 'pat-002',
    title: 'Electricity Bill Disconnection APK Trap (BSES / MSEDCL / TNEB)',
    category: 'Utility Phishing',
    detectionCount: 5120,
    riskWeight: 'HIGH (8.9/10)',
    keywords: ['power disconnect tonight', 'bill not updated', 'electricity officer', 'download quicksupport', 'pay rs 10'],
    rulesTriggered: 18,
    status: 'Active Enforced'
  },
  {
    id: 'pat-003',
    title: 'SBI / HDFC / ICICI NetBanking KYC & PAN Block',
    category: 'Banking Phishing',
    detectionCount: 6890,
    riskWeight: 'HIGH (9.1/10)',
    keywords: ['yono account blocked', 'update pan card', 'kyc verification pending', 'netbanking suspended'],
    rulesTriggered: 22,
    status: 'Active Enforced'
  },
  {
    id: 'pat-004',
    title: 'UPI "Receive Money / Scan QR" PIN Scam',
    category: 'Financial Coercion',
    detectionCount: 3410,
    riskWeight: 'HIGH (8.6/10)',
    keywords: ['enter upi pin to receive', 'phonepe cashback', 'gpay lottery reward', 'scan qr to get money'],
    rulesTriggered: 16,
    status: 'Active Enforced'
  },
  {
    id: 'pat-005',
    title: 'Jeevan Pramaan / EPFO Pension Verification Fraud',
    category: 'Social Engineering',
    detectionCount: 1980,
    riskWeight: 'HIGH (8.4/10)',
    keywords: ['life certificate expired', 'epfo pension hold', 'verify fingerprint online', 'central govt pension'],
    rulesTriggered: 12,
    status: 'Active Enforced'
  }
]

export const mockDetectionRules = [
  {
    id: 'rule-101',
    name: 'Digital Arrest / Cyber Police Coercion Filter',
    trigger: 'NLP detects ("Digital Arrest" | "Mumbai Customs" | "Aadhaar illegal parcel") + High Urgency',
    action: 'Immediate Call Quarantine + Dispatch Alert to Primary Guardian + 1930 Cybercrime draft',
    enabled: true,
    hitsToday: 42,
    accuracy: '99.4%'
  },
  {
    id: 'rule-102',
    name: 'Electricity Disconnection SMS & Malicious APK Shield',
    trigger: 'SMS contains ("power disconnected tonight" | "electricity officer") AND (phone number | APK link)',
    action: 'Quarantine SMS + Block APK Package Installer',
    enabled: true,
    hitsToday: 118,
    accuracy: '98.9%'
  },
  {
    id: 'rule-103',
    name: 'UPI Reverse PIN Entry Trap Blocker',
    trigger: 'App detects QR scan for credit while prompting for UPI PIN authorization',
    action: 'Push Emergency Guardian Confirmation Prompt + Shield UPI keypad',
    enabled: true,
    hitsToday: 31,
    accuracy: '97.8%'
  },
  {
    id: 'rule-104',
    name: 'High-Volume IMPS / RTGS Banking Spike',
    trigger: 'Cumulative bank transfers exceed user daily limit of ₹25,000 by > 150%',
    action: 'Require Biometric Dual-Approval from Senior + Family Guardian',
    enabled: true,
    hitsToday: 23,
    accuracy: '99.6%'
  }
]

export const mockHeatmapRegions = [
  { region: 'Northern Region (Delhi NCR, UP, Haryana)', threatLevel: 'Very High', incidents: 2890, trend: '+24%', topType: 'Digital Arrest & KYC Phishing' },
  { region: 'Western Region (Maharashtra, Gujarat)', threatLevel: 'High', incidents: 3420, trend: '+18%', topType: 'Electricity Bill & Courier Customs' },
  { region: 'Southern Region (Karnataka, Tamil Nadu, Telangana)', threatLevel: 'High', incidents: 2150, trend: '+12%', topType: 'UPI QR Fraud & Jeevan Pramaan' },
  { region: 'Eastern Region (West Bengal, Odisha, Bihar)', threatLevel: 'Moderate', incidents: 1340, trend: '+6%', topType: 'Lottery & Bank KYC Traps' },
  { region: 'Central Region (Madhya Pradesh, Rajasthan)', threatLevel: 'Moderate', incidents: 980, trend: '+4%', topType: 'Pension & Govt Scheme Impersonation' }
]

export const mockAuditLogs = [
  { id: 'aud-01', timestamp: '2026-08-17 11:58:12', actor: 'Rajesh Sharma (SecOps Lead)', action: 'Rule Updated', target: 'rule-101 (Digital Arrest detection threshold tuned to 90%)', ip: '10.4.0.12 (Mumbai DC)', severity: 'Info' },
  { id: 'aud-02', timestamp: '2026-08-17 11:42:05', actor: 'Automated Shield AI', action: 'Threat Neutralized', target: 'MSEDCL Electricity Phishing SMS #902 on usr-102', ip: 'System (TRAI Relay)', severity: 'High' },
  { id: 'aud-03', timestamp: '2026-08-17 10:15:33', actor: 'Pooja Iyer (SecOps)', action: 'Geofence Modified', target: 'SafeZone #2 (Ahmedabad Senior Citizens Club)', ip: '10.4.0.18', severity: 'Warning' },
  { id: 'aud-04', timestamp: '2026-08-17 09:30:19', actor: 'Crisis Dispatcher', action: 'Counselor Session Initiated', target: 'Vandrevala Crisis Session #882 for Harish Verma', ip: '10.2.1.88', severity: 'Critical' },
  { id: 'aud-05', timestamp: '2026-08-17 08:14:02', actor: 'System Daemon', action: 'Pattern Database Sync', target: 'National Cyber Crime Reporting Portal (1930) Feed v4.9', ip: 'Cron (Cert-In)', severity: 'Info' }
]
