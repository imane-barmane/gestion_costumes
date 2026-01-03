<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\Reservation;
use App\Models\Costume;

class ReservationController extends Controller{
    public function store(Request $request)
{
    $request->validate([
        'costume_id'   => 'required|exists:costumes,id',
        'client_phone' => 'required|string|min:8',
        'start_date'   => 'required|date',
        'end_date'     => 'required|date|after_or_equal:start_date',
        'cin_url'          => 'required|file|mimes:jpg,jpeg,png,pdf|max:4096',
    ]);

    // Upload CIN
    $path = $request->file('cin_url')->store('cin_uploads', 'public');

    $user = Auth::user();
    $sellerId = $user->id;

    $reservation = Reservation::create([
        'costume_id'   => $request->costume_id,
        'client_phone' => $request->client_phone,
        'cin_url'     => $path,
        'start_date'   => $request->start_date,
        'end_date'     => $request->end_date,
        'seller_id'    => $sellerId
    ]);
    $costume = Costume::findOrFail($request->costume_id);
    $costume->is_reserved = true;
    $costume->save();

    return response()->json([
        'message' => 'Réservation enregistrée avec succès',
        'reservation' => $reservation
    ], 201);
}

}
