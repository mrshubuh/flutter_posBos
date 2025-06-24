import 'package:flutter/material.dart';
import 'package:flutter_pos/data/models/response/discount_response_model.dart';
import 'package:intl/intl.dart';

class DiscountUtils {
  /// Cek apakah hari ini termasuk hari diskon
  /// validDays: 1=Senin, 7=Minggu
  static bool isTodayDiscount(List<int> validDays) {
    if (validDays.isEmpty) return true; // Jika tidak ada validDays, berlaku setiap hari
    
    final now = DateTime.now();
    // DateTime weekday: 1=Senin, 7=Minggu
    return validDays.contains(now.weekday);
  }

  /// Cek apakah diskon berlaku berdasarkan tanggal
  static bool isWithinDateRange(DiscountResponseModel discount) {
    final now = DateTime.now();
    
    // Cek start date
    if (discount.startAt != null && now.isBefore(discount.startAt!)) {
      return false;
    }
    
    // Cek expired date
    if (discount.expiredAt != null && now.isAfter(discount.expiredAt!)) {
      return false;
    }
    
    return true;
  }

  /// Cek apakah diskon berlaku berdasarkan waktu
  static bool isWithinTimeWindow(DiscountResponseModel discount) {
    if (discount.startTime == null || discount.endTime == null) {
      return true; // Jika tidak ada batasan waktu, berlaku sepanjang hari
    }
    
    final now = DateTime.now();
    final timeFormat = DateFormat('HH:mm:ss');
    
    try {
      final startTime = timeFormat.parse(discount.startTime!);
      final endTime = timeFormat.parse(discount.endTime!);
      
      final currentTime = timeFormat.parse(
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}'
      );
      
      // Handle kasus dimana waktu melewati tengah malam
      if (startTime.isBefore(endTime)) {
        return currentTime.isAfter(startTime) && currentTime.isBefore(endTime);
      } else {
        return currentTime.isAfter(startTime) || currentTime.isBefore(endTime);
      }
    } catch (e) {
      debugPrint('Error parsing time: $e');
      return false;
    }
  }

  /// Cek apakah diskon berlaku hari ini
  static bool isDiscountValidToday(DiscountResponseModel discount) {
    // Cek status diskon
    if (discount.status != 'active') return false;
    
    // Cek hari berlaku
    if (!isTodayDiscount(discount.validDays)) return false;
    
    // Cek rentang tanggal
    if (!isWithinDateRange(discount)) return false;
    
    // Cek jadwal waktu
    if (!isWithinTimeWindow(discount)) return false;
    
    return true;
  }

  /// Hitung harga setelah diskon
  static double applyDiscount(double price, DiscountResponseModel discount) {
    if (!isDiscountValidToday(discount)) return price;
    if (!meetsMinimumRequirements(price, 1, discount)) return price;

    if (discount.type == 'percentage') {
      return price - (price * discount.value / 100);
    } else if (discount.type == 'fixed') {
      final discountAmount = discount.value > price ? price : discount.value;
      return price - discountAmount;
    }
    return price;
  }

  /// Hitung diskon berdasarkan persentase
  static double applyPercentageDiscount(double price, double percentage) {
    return price - (price * percentage / 100);
  }

  /// Hitung diskon berdasarkan nilai tetap
  static double applyFixedDiscount(double price, double fixedAmount) {
    final discountAmount = fixedAmount > price ? price : fixedAmount;
    return price - discountAmount;
  }

  /// Cek apakah order memenuhi syarat minimum diskon
  static bool meetsMinimumRequirements(
      double totalPrice, int totalQuantity, DiscountResponseModel discount) {
    // Cek minimal pembelian
    if (totalPrice < discount.minAmount) return false;
    
    // Cek minimal kuantitas
    if (discount.minQuantity > 0 && totalQuantity < discount.minQuantity) {
      return false;
    }
    
    // Cek maksimal kuantitas
    if (discount.maxQuantity > 0 && totalQuantity > discount.maxQuantity) {
      return false;
    }
    
    return true;
  }
  
  /// Dapatkan daftar diskon yang berlaku hari ini
  static List<DiscountResponseModel> getValidDiscountsToday(
      List<DiscountResponseModel> allDiscounts) {
    return allDiscounts.where((discount) => isDiscountValidToday(discount)).toList();
  }
  
  /// Dapatkan diskon terbaik yang bisa diaplikasikan
  static DiscountResponseModel? getBestDiscount(
      List<DiscountResponseModel> discounts, double totalPrice, int totalQuantity) {
    DiscountResponseModel? bestDiscount;
    double maxDiscountValue = 0;
    
    for (var discount in discounts) {
      if (!isDiscountValidToday(discount)) continue;
      if (!meetsMinimumRequirements(totalPrice, totalQuantity, discount)) continue;
      
      double discountValue = 0;
      if (discount.type == 'percentage') {
        discountValue = totalPrice * (discount.value / 100);
      } else {
        discountValue = discount.value > totalPrice ? totalPrice : discount.value;
      }
      
      if (discountValue > maxDiscountValue) {
        maxDiscountValue = discountValue;
        bestDiscount = discount;
      }
    }
    
    return bestDiscount;
  }
}
