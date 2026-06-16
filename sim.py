def simulate(profitToclose, orders):
    print(f"Initial profitToclose: {profitToclose}")
    for i, order in enumerate(orders):
        orderprofit = order['profit']
        lots = order['lots']
        if orderprofit == 0: continue
        percentOfLotsToClose = abs(profitToclose / orderprofit) * 100
        
        if percentOfLotsToClose >= 100:
            closed_lots = lots
            percent_closed = 1.0
        else:
            closed_lots = lots * percentOfLotsToClose / 100
            percent_closed = percentOfLotsToClose / 100
            
        realized_loss = orderprofit * percent_closed
        print(f"Order {i}: orig_lots={lots}, orig_profit={orderprofit}, closed_lots={closed_lots:.2f}, realized={realized_loss:.2f}")
        
        profitToclose += orderprofit
        print(f"  New profitToclose: {profitToclose:.2f}")
        
        if profitToclose <= 0:
            break

# Order 85, 84, 83, 82, 81
orders = [
    {'lots': 6.36, 'profit': -34.80}, # approx for 85 (it closed 2.23, so original was larger)
    {'lots': 0.06, 'profit': -0.40},  # 84
    {'lots': 0.54, 'profit': -3.61},  # 83
    {'lots': 4.31, 'profit': -28.84}, # 82
    {'lots': 1.45, 'profit': -3.30},  # 81
]

simulate(15.75, orders)
