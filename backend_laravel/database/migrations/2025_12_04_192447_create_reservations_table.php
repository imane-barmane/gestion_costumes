<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
{
    Schema::create('reservations', function (Blueprint $table) {
        $table->id();
        $table->unsignedBigInteger('costume_id');
        $table->string('client_phone');
        $table->string('cin_url'); // stockage image/pdf
        $table->date('start_date');
        $table->date('end_date');
        $table->unsignedBigInteger('seller_id');
        $table->timestamps();

        $table->foreign('costume_id')->references('id')->on('costumes')->onDelete('cascade');
        $table->foreign('seller_id')->references('id')->on('users')->onDelete('cascade');
    });
}


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('reservations');
    }
};
