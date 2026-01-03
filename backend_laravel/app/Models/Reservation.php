<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Reservation extends Model
{
    protected $fillable = [
        'costume_id',
        'client_phone',
        'cin_url',
        'start_date',
        'end_date',
        'seller_id'
    ];

    public function costume()
    {
        return $this->belongsTo(Costume::class);
    }
}
