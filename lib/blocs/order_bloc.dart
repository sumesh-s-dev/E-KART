import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order.dart';

// Events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final String? userId;
  final String? role;

  const LoadOrders({
    this.userId,
    this.role,
  });

  @override
  List<Object?> get props => [userId, role];
}

class CreateOrder extends OrderEvent {
  final Order order;

  const CreateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatus({
    required this.orderId,
    required this.status,
  });

  @override
  List<Object?> get props => [orderId, status];
}

class FilterOrders extends OrderEvent {
  final OrderStatus? status;
  final String? searchQuery;

  const FilterOrders({
    this.status,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [status, searchQuery];
}

// States
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  final OrderStatus? statusFilter;
  final String? searchQuery;

  const OrderLoaded(
    this.orders, {
    this.statusFilter,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [orders, statusFilter, searchQuery];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final SupabaseClient _supabaseClient;
  List<Order> _allOrders = [];
  String? _currentUserId;
  String? _currentRole;

  OrderBloc({SupabaseClient? supabaseClient})
      : _supabaseClient = supabaseClient ?? Supabase.instance.client,
        super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<CreateOrder>(_onCreateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<FilterOrders>(_onFilterOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoading());

      _currentUserId = event.userId;
      _currentRole = event.role;

      var query = _supabaseClient.from('orders').select();

      // Filter orders based on user role
      if (event.role == 'seller' && event.userId != null) {
        // Sellers see orders for their products
        query = query.eq('seller_id', event.userId!);
      } else if (event.role == 'customer' && event.userId != null) {
        // Customers see their own orders
        query = query.eq('customer_id', event.userId!);
      }

      final response = await query.order('created_at', ascending: false);

      _allOrders = response.map((json) => Order.fromJson(json)).toList();
      emit(OrderLoaded(_allOrders));
    } catch (e) {
      print('Error loading orders: $e');
      emit(OrderError('Failed to load orders: ${e.toString()}'));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoading());

      final orderData = event.order.toJson();
      orderData['id'] = DateTime.now().millisecondsSinceEpoch.toString();

      await _supabaseClient.from('orders').insert(orderData);

      // Reload orders after creating new one
      add(LoadOrders(userId: _currentUserId, role: _currentRole));
    } catch (e) {
      print('Error creating order: $e');
      emit(OrderError('Failed to create order: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderState> emit,
  ) async {
    try {
      emit(OrderLoading());

      final updateData = {
        'status': event.status.toString().split('.').last,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await _supabaseClient
          .from('orders')
          .update(updateData)
          .eq('id', event.orderId);

      // Reload orders after updating
      add(LoadOrders(userId: _currentUserId, role: _currentRole));
    } catch (e) {
      print('Error updating order status: $e');
      emit(OrderError('Failed to update order status: ${e.toString()}'));
    }
  }

  void _onFilterOrders(
    FilterOrders event,
    Emitter<OrderState> emit,
  ) {
    try {
      List<Order> filteredOrders = _allOrders;

      // Filter by status
      if (event.status != null) {
        filteredOrders = filteredOrders
            .where((order) => order.status == event.status)
            .toList();
      }

      // Filter by search query (search in order ID and product ID)
      if (event.searchQuery != null && event.searchQuery!.isNotEmpty) {
        filteredOrders = filteredOrders
            .where((order) =>
                order.orderId
                    .toLowerCase()
                    .contains(event.searchQuery!.toLowerCase()) ||
                order.productId
                    .toLowerCase()
                    .contains(event.searchQuery!.toLowerCase()) ||
                order.deliveryLocation
                    .toLowerCase()
                    .contains(event.searchQuery!.toLowerCase()))
            .toList();
      }

      emit(OrderLoaded(
        filteredOrders,
        statusFilter: event.status,
        searchQuery: event.searchQuery,
      ));
    } catch (e) {
      print('Error filtering orders: $e');
      emit(OrderError('Failed to filter orders: ${e.toString()}'));
    }
  }
}
