import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<String> categories = [
    'Account Help',
    'Order Tracking',
    'Payments & Refunds',
    'Product Inquiries',
    'Seller Guidelines',
    'AR Feature Issues',
  ];

  final List<FAQ> faqs = [
    FAQ('How can I track my order?',
        'Go to My Orders from your profile and select an order to track.'),
    FAQ('How do I become a seller on Dastkaari?',
        'Open the side menu and tap "Be a Seller", then fill in the required registration info.'),
    FAQ('What payment methods are supported?',
        'You can pay using Stripe (credit/debit cards) or Cash on Delivery.'),
    FAQ('Can I use AR for every product?',
        'Only selected products with AR tags can be visualized in AR.'),
    FAQ('How do I cancel an order?',
        'Go to My Orders and click on the order you want to cancel (if not shipped).'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Help Center',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔍 Search Bar
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Help Topics',
                  hintStyle: GoogleFonts.poppins(),
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),

              // 📂 Help Categories
              Text(
                'Browse Help Categories',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3.2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                ),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {
                      // Optional: Show FAQs filtered by category
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: const Color(0xffD9A441)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: Text(
                          categories[index],
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // ❓FAQs
              Text(
                'Frequently Asked Questions',
                style: GoogleFonts.poppins(
                    fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: faqs.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ExpansionTile(
                      title: Text(
                        faqs[index].question,
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Text(
                            faqs[index].answer,
                            style: GoogleFonts.poppins(color: Colors.grey[800]),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // 📞 Contact Support
              Center(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    const phoneNumber =
                        '923429023501'; // Replace with your number
                    final url = Uri.parse(
                        "https://wa.me/$phoneNumber?text=Hello%20Support%20Team!");

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url,
                          mode: LaunchMode.externalApplication);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Could not open WhatsApp")),
                      );
                    }
                  },
                  icon: const Icon(Icons.headset_mic),
                  label: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Contact Support',
                      style: GoogleFonts.poppins(fontSize: 16),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xffD9A441),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class FAQ {
  String question;
  String answer;

  FAQ(this.question, this.answer);
}
