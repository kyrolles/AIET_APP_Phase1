import 'package:flutter/material.dart';


class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
          
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Status',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  statusTile(
                    imagePath: 'image/daca1c3b78a2c352c89eabda54e640ce.png',
                    label: 'Proof of enrollment',
                    status: 'Done',
                    statusColor: Colors.green,
                  ),
                  statusTile(
                    imagePath: 'image/9e1e8dc1064bb7ac5550ad684703fb30.png',
                    label: 'Tuition fees',
                    status: 'Done',
                    statusColor: Colors.green,
                  ),
                  statusTile(
                    imagePath: 'image/daca1c3b78a2c352c89eabda54e640ce.png',
                    label: 'Proof of enrollment',
                    status: 'Rejected',
                    statusColor: Colors.orange,
                  ),
                  statusTile(
                    imagePath: 'image/daca1c3b78a2c352c89eabda54e640ce.png',
                    label: 'Proof of enrollment',
                    status: 'Pending',
                    statusColor: Colors.yellow,
                  ),
                  statusTile(
                    imagePath: 'image/daca1c3b78a2c352c89eabda54e640ce.png',
                    label: 'Proof of enrollment',
                    status: 'No Status',
                    statusColor: Colors.grey,
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
              
              },
            
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ask for',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
              
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                
                const SizedBox(height: 10),
                 Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                
         Container(
             decoration: const BoxDecoration(
             color: Colors.white,  
             shape: BoxShape.circle, 
  ),
                 padding: const EdgeInsets.all(10),  
                     child: ClipOval(
                     child: Image.asset(
                     'image/9e1e8dc1064bb7ac5550ad684703fb30.png',  
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,  
    ),
  ),
),

                    const SizedBox(width: 15),
              
                    const Text(
                      'Tuition fees',
                      style: TextStyle(
                       fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          
               const SizedBox(height: 10),
               Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                
         Container(
             decoration: const BoxDecoration(
             color: Colors.white,  
             shape: BoxShape.circle, 
  ),
                 padding: const EdgeInsets.all(10),  
                     child: ClipOval(
                     child: Image.asset(
                     'image/daca1c3b78a2c352c89eabda54e640ce.png',  
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,  
    ),
  ),
),

                    const SizedBox(width: 15),
              
                    const Text(
                      'Proof of enrollment',
                      style: TextStyle(
                       fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ], 
            ),
            ),
              
          
            
          ],
           ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget statusTile({
  required String imagePath,
  required String label,
  required String status,
  required Color statusColor,
}) {
  return Container(
    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    margin: EdgeInsets.symmetric(vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Image.asset(
            imagePath,
            width: 24, 
            height: 24,
          ),
        ),
        SizedBox(width: 15),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
        ),
        Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(width: 10),
        CircleAvatar(
          radius: 8,
          backgroundColor: statusColor,
        ),
      ],
    ),
  );
}