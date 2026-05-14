<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width,initial-scale=1.0">
    <title>Login - Panel Admin</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        @keyframes bgFloat{0%,100%{background-position:0% 50%}50%{background-position:100% 50%}}
        @keyframes fadeUp{from{opacity:0;transform:translateY(30px) scale(.96)}to{opacity:1;transform:translateY(0) scale(1)}}
        @keyframes slideIn{from{opacity:0;transform:translateX(-30px)}to{opacity:1;transform:translateX(0)}}
        @keyframes float{0%,100%{transform:translateY(0)}50%{transform:translateY(-10px)}}
        @keyframes shimmer{0%{background-position:-200% 0}100%{background-position:200% 0}}
        @keyframes spin{to{transform:rotate(360deg)}}
        @keyframes pulseGlow{0%,100%{box-shadow:0 0 0 0 rgba(79,70,229,.4)}50%{box-shadow:0 0 30px 10px rgba(79,70,229,.15)}}

        body{
            font-family:'Inter',sans-serif;
            background:linear-gradient(-45deg,#0f172a,#1e293b,#1a1a2e,#16213e);
            background-size:400% 400%;
            animation:bgFloat 15s ease infinite;
            min-height:100vh;display:flex;align-items:center;justify-content:center;padding:20px;
            position:relative;overflow:hidden;
        }
        body::before{
            content:'';position:absolute;width:600px;height:600px;
            background:radial-gradient(circle,rgba(79,70,229,.08) 0%,transparent 70%);
            top:-200px;right:-200px;animation:float 8s ease-in-out infinite;
        }
        body::after{
            content:'';position:absolute;width:500px;height:500px;
            background:radial-gradient(circle,rgba(129,140,248,.06) 0%,transparent 70%);
            bottom:-200px;left:-200px;animation:float 10s ease-in-out infinite reverse;
        }
        .login-container{width:100%;max-width:440px;position:relative;z-index:1;animation:fadeUp .7s cubic-bezier(.16,1,.3,1) both}
        .card-login{
            background:rgba(255,255,255,.97);
            backdrop-filter:blur(30px);
            border-radius:24px;padding:44px 40px;
            box-shadow:0 25px 60px -12px rgba(0,0,0,.6),0 0 0 1px rgba(255,255,255,.05);
            animation:fadeUp .7s cubic-bezier(.16,1,.3,1) .1s both;
            position:relative;overflow:hidden;
        }
        .card-login::before{
            content:'';position:absolute;top:0;left:0;width:100%;height:4px;
            background:linear-gradient(90deg,#4f46e5,#818cf8,#a5b4fc,#4f46e5);
            background-size:300% 100%;
            animation:shimmer 3s linear infinite;
        }
        .login-header{text-align:center;margin-bottom:36px;animation:slideIn .6s cubic-bezier(.16,1,.3,1) .2s both}
        .login-header .logo-wrap{
            width:80px;height:80px;margin:0 auto 20px;
            background:white;
            border-radius:20px;display:inline-flex;align-items:center;justify-content:center;
            box-shadow:0 8px 24px rgba(79,70,229,.25);
            animation:float 4s ease-in-out infinite;
            overflow:hidden;
            padding:8px;
        }
        .login-header .logo-wrap img{
            width:100%;height:100%;object-fit:contain;
        }
        .login-header h1{font-size:24px;font-weight:800;color:#1e293b;letter-spacing:-.5px}
        .login-header p{font-size:14px;color:#64748b;margin-top:4px}
        .form-group{animation:slideIn .5s cubic-bezier(.16,1,.3,1) both}
        .form-group:nth-of-type(1){animation-delay:.3s}
        .form-group:nth-of-type(2){animation-delay:.4s}
        .form-label{font-weight:600;font-size:13px;color:#334155;margin-bottom:8px;display:block}
        .input-wrap{position:relative}
        .form-control{
            border-radius:12px;border:2px solid #e2e8f0;
            padding:14px 18px 14px 48px;font-size:14px;
            font-family:'Inter',sans-serif;background:#f8fafc;
            transition:all .3s cubic-bezier(.16,1,.3,1);width:100%;outline:none;
        }
        .form-control:hover{border-color:#cbd5e1;background:#fff}
        .form-control:focus{border-color:#4f46e5;box-shadow:0 0 0 4px rgba(79,70,229,.1);background:#fff;transform:translateY(-2px)}
        .form-control::placeholder{color:#94a3b8}
        .input-icon{
            position:absolute;left:16px;top:50%;transform:translateY(-50%);
            color:#94a3b8;font-size:18px;z-index:2;
            transition:all .3s cubic-bezier(.16,1,.3,1);
        }
        .input-wrap:focus-within .input-icon{color:#4f46e5;transform:translateY(-50%) scale(1.1)}
        .btn-login{
            background:linear-gradient(135deg,#4f46e5,#6366f1);
            border:none;border-radius:12px;padding:14px;
            font-weight:700;font-size:15px;color:#fff;width:100%;
            transition:all .35s cubic-bezier(.16,1,.3,1);
            font-family:'Inter',sans-serif;cursor:pointer;
            position:relative;overflow:hidden;
            animation:slideIn .5s cubic-bezier(.16,1,.3,1) .5s both;
        }
        .btn-login:hover{transform:translateY(-2px);box-shadow:0 12px 28px rgba(79,70,229,.4)}
        .btn-login:active{transform:translateY(0) scale(.98)}
        .btn-login:disabled{opacity:.7;cursor:not-allowed;transform:none}
        .btn-login::after{
            content:'';position:absolute;top:50%;left:50%;
            width:0;height:0;background:rgba(255,255,255,.15);
            border-radius:50%;transform:translate(-50%,-50%);
            transition:width .6s,height .6s;
        }
        .btn-login:active::after{width:400px;height:400px}
        .alert-custom{
            background:linear-gradient(135deg,#fee2e2,#fecaca);color:#991b1b;
            border-radius:12px;padding:14px 18px;font-size:13px;margin-bottom:24px;
            display:flex;align-items:center;gap:10px;
            animation:fadeUp .4s cubic-bezier(.16,1,.3,1);
        }
        .login-footer{
            text-align:center;margin-top:28px;padding-top:20px;
            border-top:1px solid #f1f5f9;
            animation:fadeUp .4s cubic-bezier(.16,1,.3,1) .6s both;
        }
        .login-footer p{font-size:13px;color:#64748b;margin-bottom:4px}
        .spinner{
            display:inline-block;width:20px;height:20px;
            border:3px solid rgba(255,255,255,.3);border-top-color:#fff;
            border-radius:50%;animation:spin .6s linear infinite;
        }
        .bg-particles{
            position:fixed;top:0;left:0;width:100%;height:100%;pointer-events:none;z-index:0;
            overflow:hidden;
        }
        .particle{
            position:absolute;width:4px;height:4px;
            background:rgba(255,255,255,.05);border-radius:50%;
            animation:float 6s ease-in-out infinite;
        }
        .particle:nth-child(1){top:10%;left:10%;animation-delay:0s;width:6px;height:6px}
        .particle:nth-child(2){top:20%;right:15%;animation-delay:1s}
        .particle:nth-child(3){top:60%;left:5%;animation-delay:2s;width:5px;height:5px}
        .particle:nth-child(4){top:80%;right:10%;animation-delay:3s}
        .particle:nth-child(5){top:40%;left:80%;animation-delay:4s;width:8px;height:8px}
        .particle:nth-child(6){top:90%;left:50%;animation-delay:2.5s}
    </style>
</head>
<body>
    <div class="bg-particles">
        <div class="particle"></div><div class="particle"></div>
        <div class="particle"></div><div class="particle"></div>
        <div class="particle"></div><div class="particle"></div>
    </div>
    <div class="login-container">
        <div class="card-login">
            <div class="login-header">
                <div class="logo-wrap">
                    <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTmINwWvAoYHkJZlok2LNRoekRZKf4Lm-c2ew&s" alt="Universitas Bumigora" loading="lazy">
                </div>
                <h1>Selamat Datang</h1>
                <p>Universitas Bumigora — Panel Admin</p>
            </div>
            @if($errors->any())
            <div class="alert-custom">
                <i class="bi bi-exclamation-triangle-fill"></i>
                {{ $errors->first() }}
            </div>
            @endif
            <form method="POST" action="{{ route('admin.login.post') }}">@csrf
                <div class="mb-4 form-group">
                    <label class="form-label">Email</label>
                    <div class="input-wrap">
                        <span class="input-icon"><i class="bi bi-envelope-fill"></i></span>
                        <input type="email" name="email" class="form-control" placeholder="admin@example.com" value="{{ old('email') }}" required autofocus>
                    </div>
                </div>
                <div class="mb-4 form-group">
                    <label class="form-label">Password</label>
                    <div class="input-wrap">
                        <span class="input-icon"><i class="bi bi-lock-fill"></i></span>
                        <input type="password" name="password" class="form-control" placeholder="Masukkan password" required>
                    </div>
                </div>
                <button type="submit" class="btn-login" id="btnLogin">
                    <span id="btnText">Masuk</span>
                    <span id="btnSpinner" class="spinner" style="display:none"></span>
                </button>
            </form>
            <div class="login-footer">
                <p>Sistem Informasi Pendidikan & Event Akademik</p>
                <small style="color:#94a3b8">&copy; {{ date('Y') }} UBG Education Event.</small>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        document.querySelector('form')?.addEventListener('submit',function(){
            document.getElementById('btnText').style.display='none';
            document.getElementById('btnSpinner').style.display='inline-block';
            document.getElementById('btnLogin').disabled=true;
        });
        document.querySelectorAll('.form-control').forEach(function(input){
            input.addEventListener('focus',function(){
                this.closest('.input-wrap').querySelector('.input-icon').style.color='#4f46e5';
            });
            input.addEventListener('blur',function(){
                if(!this.value) this.closest('.input-wrap').querySelector('.input-icon').style.color='#94a3b8';
            });
        });
    </script>
</body>
</html>
