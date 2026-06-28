<?php
namespace App\Providers;

use Illuminate\Support\Facades\URL;
use Illuminate\Support\ServiceProvider;

class HttpsProvider extends ServiceProvider
{
    public function boot(): void
    {
        if ($this->app->environment('production') || env('FORCE_HTTPS')) {
            URL::forceScheme('https');
        }
    }
}
