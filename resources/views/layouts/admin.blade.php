<!DOCTYPE html>
<html lang="id" data-bs-theme="light">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>@yield('title', 'Admin Panel') - Sistem Informasi Pendidikan & Event Akademik</title>

    <!-- Bootstrap 5 + Icons -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <!-- Google Fonts Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <!-- Universitas Bumigora Favicon -->
    <link rel="icon" href="https://bumigora.ac.id/wp-content/uploads/2022/11/cropped-Logo-Universitas-Bumigora-32x32.png" sizes="32x32">
    <link rel="icon" href="https://bumigora.ac.id/wp-content/uploads/2022/11/cropped-Logo-Universitas-Bumigora-192x192.png" sizes="192x192">
    <!-- Chart.js -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>

    <style>
        :root {
            --primary: #4f46e5;
            --primary-dark: #4338ca;
            --primary-light: #eef2ff;
            --secondary: #64748b;
            --success: #10b981;
            --warning: #f59e0b;
            --danger: #ef4444;
            --info: #3b82f6;
            --dark: #1e293b;
            --gray-50: #f8fafc;
            --gray-100: #f1f5f9;
            --gray-200: #e2e8f0;
            --gray-300: #cbd5e1;
            --gray-400: #94a3b8;
            --gray-500: #64748b;
            --gray-600: #475569;
            --gray-700: #334155;
            --gray-800: #1e293b;
            --gray-900: #0f172a;
            --sidebar-width: 280px;
            --sidebar-collapsed: 80px;
            --header-height: 70px;
            --radius: 12px;
            --radius-sm: 8px;
            --shadow-sm: 0 1px 3px rgba(0,0,0,.06), 0 1px 2px rgba(0,0,0,.04);
            --shadow: 0 4px 6px -1px rgba(0,0,0,.07), 0 2px 4px -2px rgba(0,0,0,.05);
            --shadow-lg: 0 10px 15px -3px rgba(0,0,0,.08), 0 4px 6px -4px rgba(0,0,0,.04);
            --shadow-xl: 0 20px 25px -5px rgba(0,0,0,.1), 0 8px 10px -6px rgba(0,0,0,.04);
            --ease-out-expo: cubic-bezier(0.16, 1, 0.3, 1);
            --ease-spring: cubic-bezier(0.34, 1.56, 0.64, 1);
        }

        * { margin: 0; padding: 0; box-sizing: border-box; }

        body {
            font-family: 'Inter', -apple-system, BlinkMacSystemFont, sans-serif;
            background: var(--gray-50);
            color: var(--gray-800);
            min-height: 100vh;
            overflow-x: hidden;
        }

        /* ===== SMOOTH SCROLLBAR ===== */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: transparent; }
        ::-webkit-scrollbar-thumb { background: var(--gray-300); border-radius: 10px; }
        ::-webkit-scrollbar-thumb:hover { background: var(--gray-400); }

        /* ===== ANIMATIONS GLOBAL ===== */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(12px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(24px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes fadeInLeft {
            from { opacity: 0; transform: translateX(-20px); }
            to { opacity: 1; transform: translateX(0); }
        }
        @keyframes fadeInRight {
            from { opacity: 0; transform: translateX(20px); }
            to { opacity: 1; transform: translateX(0); }
        }
        @keyframes scaleIn {
            from { opacity: 0; transform: scale(.92); }
            to { opacity: 1; transform: scale(1); }
        }
        @keyframes slideDown {
            from { opacity: 0; transform: translateY(-16px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes pulseGlow {
            0%, 100% { box-shadow: 0 0 0 0 rgba(79,70,229,.3); }
            50% { box-shadow: 0 0 20px 6px rgba(79,70,229,.1); }
        }
        @keyframes shimmer {
            0% { background-position: -200% 0; }
            100% { background-position: 200% 0; }
        }
        @keyframes countUp {
            from { opacity: 0; transform: translateY(10px); }
            to { opacity: 1; transform: translateY(0); }
        }
        @keyframes float {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-6px); }
        }
        @keyframes spinSlow {
            to { transform: rotate(360deg); }
        }
        @keyframes slideInRight {
            from { opacity: 0; transform: translateX(100%); }
            to { opacity: 1; transform: translateX(0); }
        }
        @keyframes slideOutRight {
            from { opacity: 1; transform: translateX(0); }
            to { opacity: 0; transform: translateX(100%); }
        }

        .animate-fade-in { animation: fadeIn .5s var(--ease-out-expo) both; }
        .animate-fade-up { animation: fadeInUp .6s var(--ease-out-expo) both; }
        .animate-scale { animation: scaleIn .4s var(--ease-spring) both; }
        .animate-slide-down { animation: slideDown .4s var(--ease-out-expo) both; }

        /* Page transition wrapper */
        .page-content {
            padding: 28px 32px;
            animation: fadeIn .45s var(--ease-out-expo);
        }

        /* ===== SIDEBAR ===== */
        .sidebar {
            position: fixed;
            top: 0;
            left: 0;
            width: var(--sidebar-width);
            height: 100vh;
            background: linear-gradient(180deg, #0f172a 0%, #1a2332 100%);
            color: white;
            z-index: 1040;
            transition: width .35s var(--ease-out-expo);
            overflow-y: auto;
            overflow-x: hidden;
            border-right: 1px solid rgba(255,255,255,.04);
        }
        .sidebar::-webkit-scrollbar { width: 3px; }
        .sidebar::-webkit-scrollbar-thumb { background: rgba(255,255,255,.08); border-radius: 4px; }

        .sidebar-brand {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 20px 24px;
            border-bottom: 1px solid rgba(255,255,255,.05);
            min-height: var(--header-height);
            text-decoration: none;
            animation: fadeIn .5s var(--ease-out-expo);
        }
        .sidebar-brand .brand-icon {
            width: 42px;
            height: 42px;
            background: linear-gradient(135deg, var(--primary), #818cf8);
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 20px;
            color: white;
            flex-shrink: 0;
            animation: float 3s ease-in-out infinite;
        }
        .sidebar-brand .brand-text {
            font-weight: 700;
            font-size: 16px;
            color: white;
            line-height: 1.3;
            white-space: nowrap;
        }
        .sidebar-brand .brand-text small {
            display: block;
            font-weight: 400;
            font-size: 11px;
            color: var(--gray-400);
        }

        .sidebar-nav { padding: 12px; }
        .sidebar-nav .nav-label {
            font-size: 10px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: 1.2px;
            color: var(--gray-500);
            padding: 12px 14px 6px;
            margin-top: 4px;
            animation: fadeIn .5s var(--ease-out-expo) both;
        }
        .sidebar-nav .nav-item {
            display: flex;
            align-items: center;
            gap: 14px;
            padding: 11px 14px;
            margin: 2px 0;
            border-radius: var(--radius-sm);
            color: var(--gray-300);
            text-decoration: none;
            font-size: 14px;
            font-weight: 500;
            transition: all .25s var(--ease-out-expo);
            position: relative;
            overflow: hidden;
            animation: fadeInLeft .4s var(--ease-out-expo) both;
        }
        /* Staggered animation for nav items */
        .sidebar-nav .nav-item:nth-child(2) { animation-delay: .05s; }
        .sidebar-nav .nav-item:nth-child(3) { animation-delay: .1s; }
        .sidebar-nav .nav-item:nth-child(4) { animation-delay: .15s; }
        .sidebar-nav .nav-item:nth-child(5) { animation-delay: .2s; }
        .sidebar-nav .nav-item:nth-child(6) { animation-delay: .25s; }

        .sidebar-nav .nav-item::before {
            content: '';
            position: absolute;
            left: 0;
            top: 0;
            height: 100%;
            width: 3px;
            background: var(--primary);
            transform: scaleY(0);
            transition: transform .25s var(--ease-out-expo);
            border-radius: 0 2px 2px 0;
        }
        .sidebar-nav .nav-item:hover::before,
        .sidebar-nav .nav-item.active::before {
            transform: scaleY(1);
        }
        .sidebar-nav .nav-item:hover {
            background: rgba(255,255,255,.06);
            color: white;
            padding-left: 18px;
        }
        .sidebar-nav .nav-item.active {
            background: linear-gradient(135deg, var(--primary), #6366f1);
            color: white;
            box-shadow: 0 4px 16px rgba(79,70,229,.35);
            animation: pulseGlow 2s ease-in-out infinite;
        }
        .sidebar-nav .nav-item i { font-size: 18px; width: 22px; text-align: center; flex-shrink: 0; transition: transform .3s var(--ease-spring); }
        .sidebar-nav .nav-item:hover i { transform: scale(1.15); }
        .sidebar-nav .nav-item .nav-badge {
            margin-left: auto;
            background: rgba(255,255,255,.15);
            padding: 1px 10px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            animation: scaleIn .3s var(--ease-spring);
        }
        .sidebar-nav .nav-item.active .nav-badge { background: rgba(255,255,255,.2); }

        /* ===== MAIN CONTENT ===== */
        .main-content {
            margin-left: var(--sidebar-width);
            min-height: 100vh;
            transition: margin-left .35s var(--ease-out-expo);
        }

        /* ===== HEADER ===== */
        .header {
            position: sticky;
            top: 0;
            z-index: 1030;
            background: rgba(255,255,255,.82);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid var(--gray-200);
            padding: 0 32px;
            height: var(--header-height);
            display: flex;
            align-items: center;
            justify-content: space-between;
            animation: slideDown .4s var(--ease-out-expo);
        }
        .header-left { display: flex; align-items: center; gap: 16px; }
        .header-left h5 { margin: 0; font-weight: 600; font-size: 18px; color: var(--gray-800); }
        .header-left p { margin: 0; font-size: 13px; color: var(--gray-500); }

        .header-right { display: flex; align-items: center; gap: 12px; }
        .header-right .btn-icon {
            width: 40px; height: 40px;
            border-radius: var(--radius-sm);
            border: 1px solid var(--gray-200);
            background: white;
            display: flex;
            align-items: center;
            justify-content: center;
            color: var(--gray-600);
            font-size: 18px;
            transition: all .25s var(--ease-out-expo);
            position: relative;
        }
        .header-right .btn-icon:hover {
            background: var(--primary-light);
            color: var(--primary);
            border-color: var(--primary);
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(79,70,229,.15);
        }
        .header-right .btn-icon:active { transform: scale(.92); }
        .header-right .btn-icon .badge-dot {
            position: absolute;
            top: 6px;
            right: 6px;
            width: 8px;
            height: 8px;
            background: var(--danger);
            border-radius: 50%;
            border: 2px solid white;
            animation: pulseGlow 2s ease-in-out infinite;
        }

        .user-dropdown {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 6px 12px 6px 6px;
            border-radius: 50px;
            border: 1px solid var(--gray-200);
            background: white;
            cursor: pointer;
            transition: all .25s var(--ease-out-expo);
        }
        .user-dropdown:hover {
            background: var(--gray-50);
            border-color: var(--gray-300);
            box-shadow: var(--shadow);
        }
        .user-dropdown:active { transform: scale(.97); }
        .user-dropdown .avatar {
            width: 34px; height: 34px;
            border-radius: 50%;
            background: linear-gradient(135deg, var(--primary), #818cf8);
            display: flex;
            align-items: center;
            justify-content: center;
            color: white;
            font-weight: 600;
            font-size: 14px;
        }
        .user-dropdown .user-info { line-height: 1.3; }
        .user-dropdown .user-info .name { font-size: 13px; font-weight: 600; color: var(--gray-800); }
        .user-dropdown .user-info .role { font-size: 11px; color: var(--gray-500); text-transform: capitalize; }

        /* ===== CARDS ===== */
        .card {
            border: 1px solid var(--gray-200);
            border-radius: var(--radius);
            box-shadow: var(--shadow-sm);
            transition: all .35s var(--ease-out-expo);
            background: white;
            animation: fadeInUp .5s var(--ease-out-expo) both;
        }
        /* Staggered card animation for grid items */
        .row.g-4 > [class*="col-"]:nth-child(1) .card { animation-delay: 0s; }
        .row.g-4 > [class*="col-"]:nth-child(2) .card { animation-delay: .08s; }
        .row.g-4 > [class*="col-"]:nth-child(3) .card { animation-delay: .16s; }
        .row.g-4 > [class*="col-"]:nth-child(4) .card { animation-delay: .24s; }
        .card:hover {
            box-shadow: var(--shadow-lg);
            transform: translateY(-3px);
            border-color: var(--gray-300);
        }
        .card-header {
            background: white;
            border-bottom: 1px solid var(--gray-100);
            padding: 18px 24px;
            font-weight: 600;
            font-size: 15px;
            border-radius: var(--radius) var(--radius) 0 0 !important;
        }
        .card-body { padding: 24px; }
        .card-footer {
            background: var(--gray-50);
            border-top: 1px solid var(--gray-100);
            padding: 14px 24px;
            border-radius: 0 0 var(--radius) var(--radius) !important;
        }

        /* ===== STAT CARDS WITH ANIMATION ===== */
        .stat-card {
            padding: 22px 24px;
            border-radius: var(--radius);
            background: white;
            border: 1px solid var(--gray-200);
            box-shadow: var(--shadow-sm);
            transition: all .35s var(--ease-out-expo);
            position: relative;
            overflow: hidden;
            animation: fadeInUp .5s var(--ease-out-expo) both;
        }
        .row.g-4 > [class*="col-"]:nth-child(1) .stat-card { animation-delay: 0s; }
        .row.g-4 > [class*="col-"]:nth-child(2) .stat-card { animation-delay: .08s; }
        .row.g-4 > [class*="col-"]:nth-child(3) .stat-card { animation-delay: .16s; }
        .row.g-4 > [class*="col-"]:nth-child(4) .stat-card { animation-delay: .24s; }
        .stat-card::after {
            content: '';
            position: absolute;
            top: 0; left: 0; width: 100%; height: 3px;
            background: linear-gradient(90deg, var(--primary), #818cf8, #a5b4fc, var(--primary));
            background-size: 200% 100%;
            animation: shimmer 3s linear infinite;
        }
        .stat-card:hover {
            transform: translateY(-4px);
            box-shadow: var(--shadow-xl);
        }
        .stat-card:active { transform: translateY(-1px); }
        .stat-card .stat-icon {
            width: 48px; height: 48px;
            border-radius: var(--radius-sm);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 22px;
            margin-bottom: 14px;
            transition: transform .3s var(--ease-spring);
        }
        .stat-card:hover .stat-icon { transform: scale(1.1) rotate(-3deg); }
        .stat-card .stat-value {
            font-size: 28px;
            font-weight: 800;
            color: var(--gray-900);
            line-height: 1.2;
            animation: countUp .6s var(--ease-out-expo);
        }
        .stat-card .stat-label {
            font-size: 13px;
            color: var(--gray-500);
            font-weight: 500;
            margin-top: 2px;
        }
        .stat-card .stat-change {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-size: 12px;
            font-weight: 600;
            padding: 2px 10px;
            border-radius: 20px;
            margin-top: 8px;
            transform-origin: left;
            animation: scaleIn .3s var(--ease-spring) both;
        }
        .stat-card .stat-change.up { background: #d1fae5; color: #059669; }
        .stat-card .stat-change.down { background: #fee2e2; color: #dc2626; }
        .stat-card .stat-bg-icon {
            position: absolute;
            right: -8px;
            bottom: -8px;
            font-size: 80px;
            opacity: .04;
            color: var(--gray-900);
            transition: all .4s var(--ease-out-expo);
        }
        .stat-card:hover .stat-bg-icon {
            transform: scale(1.2) rotate(-10deg);
            opacity: .07;
        }

        /* ===== TABLES SMOOTH ===== */
        .table {
            margin-bottom: 0;
            font-size: 14px;
        }
        .table thead th {
            background: var(--gray-50);
            color: var(--gray-600);
            font-weight: 600;
            font-size: 12px;
            text-transform: uppercase;
            letter-spacing: .5px;
            padding: 12px 16px;
            border-bottom: 2px solid var(--gray-200);
        }
        .table tbody td {
            padding: 12px 16px;
            vertical-align: middle;
            border-color: var(--gray-100);
            transition: all .2s var(--ease-out-expo);
        }
        .table tbody tr {
            transition: all .2s var(--ease-out-expo);
            animation: fadeIn .3s var(--ease-out-expo) both;
        }
        .table tbody tr:nth-child(1) { animation-delay: 0s; }
        .table tbody tr:nth-child(2) { animation-delay: .05s; }
        .table tbody tr:nth-child(3) { animation-delay: .1s; }
        .table tbody tr:nth-child(4) { animation-delay: .15s; }
        .table tbody tr:nth-child(5) { animation-delay: .2s; }
        .table tbody tr:hover {
            background: var(--gray-50);
            transform: scale(1.002);
        }

        /* ===== BADGES ANIMATED ===== */
        .badge-role {
            padding: 4px 12px;
            border-radius: 20px;
            font-size: 11px;
            font-weight: 600;
            text-transform: capitalize;
            transition: all .25s var(--ease-out-expo);
        }
        .badge-role:hover { transform: scale(1.05); }
        .badge-role.admin { background: #eef2ff; color: #4f46e5; }
        .badge-role.dosen { background: #dbeafe; color: #2563eb; }
        .badge-role.mahasiswa { background: #d1fae5; color: #059669; }

        /* ===== FORMS SMOOTH ===== */
        .form-control, .form-select {
            border-radius: var(--radius-sm);
            border: 1.5px solid var(--gray-200);
            padding: 10px 14px;
            font-size: 14px;
            font-family: 'Inter', sans-serif;
            transition: all .25s var(--ease-out-expo);
        }
        .form-control:hover, .form-select:hover { border-color: var(--gray-300); }
        .form-control:focus, .form-select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79,70,229,.12);
            transform: translateY(-1px);
        }
        .form-label {
            font-weight: 600;
            font-size: 13px;
            color: var(--gray-700);
            margin-bottom: 6px;
        }
        textarea.form-control { transition: all .25s var(--ease-out-expo); }
        textarea.form-control:focus { min-height: 120px; }

        /* ===== BUTTONS SMOOTH ===== */
        .btn {
            border-radius: var(--radius-sm);
            font-weight: 600;
            font-size: 14px;
            padding: 10px 20px;
            transition: all .25s var(--ease-out-expo);
            font-family: 'Inter', sans-serif;
            position: relative;
            overflow: hidden;
        }
        .btn::after {
            content: '';
            position: absolute;
            top: 50%; left: 50%;
            width: 0; height: 0;
            background: rgba(255,255,255,.15);
            border-radius: 50%;
            transform: translate(-50%, -50%);
            transition: width .5s, height .5s;
        }
        .btn:active::after { width: 300px; height: 300px; }
        .btn-primary {
            background: linear-gradient(135deg, var(--primary), #6366f1);
            border: none;
            color: white;
            background-size: 200% 200%;
            animation: shimmer 3s linear infinite;
        }
        .btn-primary:hover {
            background: linear-gradient(135deg, var(--primary-dark), #4f46e5);
            background-size: 200% 200%;
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(79,70,229,.4);
        }
        .btn-primary:active { transform: scale(.96); }
        .btn-outline-primary {
            color: var(--primary);
            border: 1.5px solid var(--primary);
        }
        .btn-outline-primary:hover {
            background: var(--primary);
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 4px 12px rgba(79,70,229,.2);
        }
        .btn-sm { padding: 6px 14px; font-size: 12px; }
        .btn-sm:hover { transform: translateY(-1px); }
        .btn-danger { background: var(--danger); border: none; }
        .btn-danger:hover { background: #dc2626; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(239,68,68,.35); }
        .btn-danger:active { transform: scale(.96); }
        .btn-success { background: var(--success); border: none; }
        .btn-success:hover { background: #059669; transform: translateY(-2px); box-shadow: 0 6px 16px rgba(16,185,129,.35); }
        .btn-success:active { transform: scale(.96); }
        .btn-warning { background: var(--warning); border: none; color: white; }
        .btn-warning:hover { background: #d97706; transform: translateY(-2px); color: white; box-shadow: 0 6px 16px rgba(245,158,11,.35); }

        /* ===== ALERTS ANIMATED ===== */
        .alert {
            border-radius: var(--radius-sm);
            border: none;
            padding: 14px 18px;
            font-size: 14px;
            animation: fadeIn .4s var(--ease-out-expo);
        }
        .alert-success { background: linear-gradient(135deg, #d1fae5, #a7f3d0); color: #065f46; }
        .alert-danger { background: linear-gradient(135deg, #fee2e2, #fecaca); color: #991b1b; }
        .alert-warning { background: linear-gradient(135deg, #fef3c7, #fde68a); color: #92400e; }
        .alert-info { background: linear-gradient(135deg, #dbeafe, #bfdbfe); color: #1e40af; }

        /* ===== PAGINATION SMOOTH ===== */
        .pagination { margin-top: 20px; gap: 4px; }
        .page-link {
            border-radius: var(--radius-sm) !important;
            border: 1px solid var(--gray-200);
            color: var(--gray-700);
            font-weight: 500;
            padding: 8px 14px;
            font-size: 13px;
            transition: all .2s var(--ease-out-expo);
        }
        .page-link:hover {
            transform: translateY(-2px);
            box-shadow: var(--shadow);
            border-color: var(--primary);
            color: var(--primary);
        }
        .page-item.active .page-link {
            background: linear-gradient(135deg, var(--primary), #6366f1);
            border-color: var(--primary);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(79,70,229,.3);
        }
        .page-item.disabled .page-link { color: var(--gray-400); }

        /* ===== UTILITY ===== */
        .text-gradient {
            background: linear-gradient(135deg, var(--primary), #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }
        .bg-soft-primary { background: var(--primary-light); }
        .bg-soft-success { background: #d1fae5; }
        .bg-soft-warning { background: #fef3c7; }
        .bg-soft-danger { background: #fee2e2; }
        .bg-soft-info { background: #dbeafe; }

        .text-primary-gradient {
            background: linear-gradient(135deg, var(--primary), #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* ===== RESPONSIVE ===== */
        @media (max-width: 992px) {
            .sidebar {
                width: var(--sidebar-collapsed);
            }
            .sidebar .brand-text,
            .sidebar .nav-label,
            .sidebar .nav-item span,
            .sidebar .nav-badge { display: none; }
            .sidebar .nav-item { justify-content: center; padding: 12px; }
            .sidebar .nav-item i { margin: 0; font-size: 20px; }
            .sidebar-brand { justify-content: center; padding: 16px; }
            .sidebar-brand .brand-icon { margin: 0; }
            .main-content { margin-left: var(--sidebar-collapsed); }
            .header { padding: 0 20px; }
            .page-content { padding: 20px; }
        }

        /* ===== LOADING ANIMATION ===== */
        .loading-spinner {
            width: 20px; height: 20px;
            border: 2.5px solid var(--gray-200);
            border-top-color: var(--primary);
            border-radius: 50%;
            animation: spin .6s linear infinite;
        }
        @keyframes spin { to { transform: rotate(360deg); } }

        /* ===== TIMELINE ===== */
        .timeline { position: relative; padding-left: 24px; }
        .timeline::before {
            content: '';
            position: absolute;
            left: 6px;
            top: 0;
            bottom: 0;
            width: 2px;
            background: var(--gray-200);
        }
        .timeline-item {
            position: relative;
            padding-bottom: 20px;
        }
        .timeline-item::before {
            content: '';
            position: absolute;
            left: -20px;
            top: 4px;
            width: 10px;
            height: 10px;
            border-radius: 50%;
            background: var(--primary);
            border: 2px solid white;
            box-shadow: 0 0 0 2px var(--primary);
        }
        .timeline-item .time { font-size: 12px; color: var(--gray-500); }
        .timeline-item .title { font-weight: 600; font-size: 14px; }

        /* ===== ALERT FLASH ===== */
        .alert-flash {
            position: fixed;
            top: 20px;
            right: 20px;
            z-index: 9999;
            min-width: 320px;
            max-width: 450px;
            animation: slideIn .3s ease;
        }
        @keyframes slideIn {
            from { transform: translateX(100%); opacity: 0; }
            to { transform: translateX(0); opacity: 1; }
        }
    </style>
</head>
<body>

    <!-- ===== SIDEBAR ===== -->
    <aside class="sidebar">
        <a href="{{ route('admin.dashboard') }}" class="sidebar-brand">
            <div class="brand-icon" style="background:white; padding:4px;">
                <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmINwWvAoYHkJZlok2LNRoekRZKf4Lm-c2ew&s" alt="UNBI" style="width:34px;height:34px;object-fit:contain;">
            </div>
            <div class="brand-text">
                UNBI EduEvent
                <small>Universitas Bumigora</small>
            </div>
        </a>

        <nav class="sidebar-nav">
            <div class="nav-label">Menu Utama</div>

            <a href="{{ route('admin.dashboard') }}" class="nav-item {{ request()->routeIs('admin.dashboard') ? 'active' : '' }}">
                <i class="bi bi-grid-1x2-fill"></i>
                <span>Dashboard</span>
                @if($unreadNotifikasi ?? false > 0)
                    <span class="nav-badge">{{ $unreadNotifikasi ?? 0 }}</span>
                @endif
            </a>

            <a href="{{ route('admin.events.index') }}" class="nav-item {{ request()->routeIs('admin.events.*') ? 'active' : '' }}">
                <i class="bi bi-calendar-event-fill"></i>
                <span>Events</span>
            </a>

            <a href="{{ route('admin.informasis.index') }}" class="nav-item {{ request()->routeIs('admin.informasis.*') ? 'active' : '' }}">
                <i class="bi bi-megaphone-fill"></i>
                <span>Informasi</span>
            </a>

            <div class="nav-label">Manajemen</div>

            <a href="{{ route('admin.users.index') }}" class="nav-item {{ request()->routeIs('admin.users.*') ? 'active' : '' }}">
                <i class="bi bi-people-fill"></i>
                <span>Users</span>
            </a>

            <div class="nav-label" style="margin-top:24px">Lainnya</div>

            <a href="{{ route('admin.logout') }}" class="nav-item" onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                <i class="bi bi-box-arrow-left"></i>
                <span>Logout</span>
            </a>
            <form id="logout-form" action="{{ route('admin.logout') }}" method="POST" style="display: none;">
                @csrf
            </form>
        </nav>
    </aside>

    <!-- ===== MAIN CONTENT ===== -->
    <div class="main-content">
        <!-- Header -->
        <header class="header">
            <div class="header-left">
                <div>
                    <h5>@yield('page-title', 'Dashboard')</h5>
                    <p>@yield('page-subtitle', 'Overview sistem informasi akademik')</p>
                </div>
            </div>
            <div class="header-right">
                <a href="#" class="btn-icon" title="Notifikasi">
                    <i class="bi bi-bell-fill"></i>
                    @if(isset($unreadNotifikasi) && $unreadNotifikasi > 0)
                        <span class="badge-dot"></span>
                    @endif
                </a>
                <div class="dropdown">
                    <div class="user-dropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <div class="avatar">
                            {{ strtoupper(substr(auth()->user()->nama ?? 'U', 0, 1)) }}
                        </div>
                        <div class="user-info d-none d-md-block">
                            <div class="name">{{ auth()->user()->nama ?? 'User' }}</div>
                            <div class="role">{{ auth()->user()->role ?? '-' }}</div>
                        </div>
                        <i class="bi bi-chevron-down text-muted" style="font-size:12px"></i>
                    </div>
                    <ul class="dropdown-menu dropdown-menu-end shadow" style="border-radius:10px; border:1px solid var(--gray-200); min-width:200px;">
                        <li>
                            <a class="dropdown-item" href="{{ route('admin.dashboard') }}">
                                <i class="bi bi-person me-2"></i> Profile
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <a class="dropdown-item text-danger" href="{{ route('admin.logout') }}"
                               onclick="event.preventDefault(); document.getElementById('logout-form').submit();">
                                <i class="bi bi-box-arrow-right me-2"></i> Logout
                            </a>
                        </li>
                    </ul>
                </div>
            </div>
        </header>

        <!-- Page Content -->
        <div class="page-content">
            @if(session('success'))
                <div class="alert alert-success alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                    <i class="bi bi-check-circle-fill"></i>
                    {{ session('success') }}
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                </div>
            @endif

            @if(session('error'))
                <div class="alert alert-danger alert-dismissible fade show d-flex align-items-center gap-2" role="alert">
                    <i class="bi bi-exclamation-triangle-fill"></i>
                    {{ session('error') }}
                    <button type="button" class="btn-close ms-auto" data-bs-dismiss="alert"></button>
                </div>
            @endif

            @yield('content')
        </div>
    </div>

    <!-- Bootstrap JS -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

    @stack('scripts')
    <script>
        // Auto-close alerts after 5s
        document.addEventListener('DOMContentLoaded', function() {
            document.querySelectorAll('.alert-dismissible').forEach(function(alert) {
                setTimeout(function() {
                    var bsAlert = new bootstrap.Alert(alert);
                    bsAlert.close();
                }, 5000);
            });
        });
    </script>
</body>
</html>
