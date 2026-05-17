<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Reset Password - Panel Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        :root{--primary:#4f46e5}
        *{margin:0;padding:0;box-sizing:border-box}
        @keyframes bgFloat{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
        @keyframes fadeUp{from{opacity:0;transform:translateY(30px) scale(.96)}to{opacity:1;transform:translateY(0) scale(1)}}
        body{
            font-family:'Inter',sans-serif;
            background:linear-gradient(-45deg,#0f172a,#1e293b,#1a1a2e,#16213e);
            background-size:400% 400%;
            animation:bgFloat 15s ease infinite;
            min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;
        }
        .card-reset{
            background:rgba(255,255,255,.97);backdrop-filter:blur(30px);
            border-radius:24px;padding:44px 40px;
            box-shadow:0 25px 60px -12px rgba(0,0,0,.6);
            width:100%;max-width:440px;animation:fadeUp .7s cubic-bezier(.16,1,.3,1) both;
            position:relative;overflow:hidden;
        }
        .card-reset::before{
            content:'';position:absolute;top:0;left:0;width:100%;height:4px;
            background:linear-gradient(90deg,#4f46e5,#818cf8,#a5b4fc,#4f46e5);
            background-size:300% 100%;
            animation:shimmer 3s linear infinite;
        }
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        .header{text-align:center;margin-bottom:32px}
        .header h1{font-size:22px;font-weight:800;color:#1e293b}
        .header p{font-size:14px;color:#64748b;margin-top:4px}
        .form-control{
            border-radius:12px;border:2px solid #e2e8f0;
            padding:14px 18px;font-size:14px;
            font-family:'Inter',sans-serif;background:#f8fafc;
            transition:all .3s;width:100%;outline:none;
        }
        .form-control:focus{border-color:#4f46e5;box-shadow:0 0 0 4px rgba(79,70,229,.1);background:#fff}
        .form-label{font-weight:600;font-size:13px;color:#334155;margin-bottom:8px;display:block}
        .btn-primary{
            background:linear-gradient(135deg,#4f46e5,#6366f1);border:none;
            border-radius:12px;padding:14px;font-weight:700;font-size:15px;color:#fff;width:100%;
            transition:all .35s;font-family:'Inter',sans-serif;cursor:pointer;
        }
        .btn-primary:hover{transform:translateY(-2px);box-shadow:0 12px 28px rgba(79,70,229,.4)}
        .btn-back{
            display:block;text-align:center;margin-top:16px;
            color:#64748b;font-size:13px;text-decoration:none;
        }
        .btn-back:hover{color:#4f46e5}
        .alert-custom{
            background:linear-gradient(135deg,#fee2e2,#fecaca);color:#991b1b;
            border-radius:12px;padding:14px 18px;font-size:13px;margin-bottom:24px;
            display:flex;align-items:center;gap:10px;
        }
    </style>
</head>
<body>
    <div class="card-reset">
        <div class="header">
            <div style="width:64px;height:64px;margin:0 auto 16px;background:white;border-radius:16px;display:flex;align-items:center;justify-content:center;box-shadow:0 8px 24px rgba(79,70,229,.25);overflow:hidden;padding:8px;">
                <img src="{{ asset('images/ubg.png') }}" alt="UBG" style="width:100%;height:100%;object-fit:contain;">
            </div>
            <h1>Reset Password</h1>
            <p>Buat password baru Anda</p>
        </div>

        @if(session('error') || $errors->any())
        <div class="alert-custom">
            <i class="bi bi-exclamation-triangle-fill"></i>
            {{ session('error') ?? $errors->first() }}
        </div>
        @endif

        <form method="POST" action="{{ route('admin.password.update') }}">@csrf
            <input type="hidden" name="token" value="{{ $token }}">
            <input type="hidden" name="email" value="{{ $email }}">

            <div class="mb-4">
                <label class="form-label">Password Baru</label>
                <input type="password" name="password" class="form-control" placeholder="Min. 6 karakter" required minlength="6">
            </div>
            <div class="mb-4">
                <label class="form-label">Konfirmasi Password</label>
                <input type="password" name="password_confirmation" class="form-control" placeholder="Ulangi password baru" required minlength="6">
            </div>
            <button type="submit" class="btn-primary">Reset Password</button>
        </form>
        <a href="{{ route('admin.login') }}" class="btn-back"><i class="bi bi-arrow-left me-1"></i>Kembali ke Login</a>
    </div>
</body>
</html>
