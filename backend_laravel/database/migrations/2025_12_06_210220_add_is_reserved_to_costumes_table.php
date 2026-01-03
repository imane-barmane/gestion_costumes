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
    Schema::table('costumes', function (Blueprint $table) {
        if (!Schema::hasColumn('costumes', 'is_reserved')) {
            $table->boolean('is_reserved')->default(false);
        }
    });
}

public function down()
{
    Schema::table('costumes', function (Blueprint $table) {
        if (Schema::hasColumn('costumes', 'is_reserved')) {
            $table->dropColumn('is_reserved');
        }
    });
}

};
