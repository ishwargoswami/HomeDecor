import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:decor_home/models/project_model.dart';
import 'package:decor_home/services/decor_provider.dart';
import 'package:decor_home/util/const.dart';
import 'package:provider/provider.dart';

class ProjectDashboardScreen extends StatefulWidget {
  @override
  _ProjectDashboardScreenState createState() => _ProjectDashboardScreenState();
}

class _ProjectDashboardScreenState extends State<ProjectDashboardScreen> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Project Dashboard'),
        elevation: 0,
      ),
      body: Consumer<DecorProvider>(
        builder: (context, provider, child) {
          final projects = provider.projects;
          
          if (projects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 100,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 20),
                  Text(
                    'No projects to analyze',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Create projects to see metrics',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(context, '/add_project');
                    },
                    icon: Icon(Icons.add),
                    label: Text('Add Project'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.lightAccent,
                    ),
                  ),
                ],
              ),
            );
          }

          // Calculate dashboard metrics
          final totalProjects = projects.length;
          final completedProjects = projects.where((p) => (p.progress ?? 0) >= 0.95).length;
          final inProgressProjects = projects.where((p) => (p.progress ?? 0) > 0.1 && (p.progress ?? 0) < 0.95).length;
          final notStartedProjects = projects.where((p) => (p.progress ?? 0) <= 0.1).length;
          
          // Calculate room distribution
          final roomDistribution = <String, int>{};
          for (var project in projects) {
            final room = project.room ?? 'Other';
            roomDistribution[room] = (roomDistribution[room] ?? 0) + 1;
          }
          
          // Calculate total budget
          final totalBudget = projects.fold<double>(
            0, (sum, project) => sum + (project.budget ?? 0)
          );
          
          // Calculate average progress
          final averageProgress = projects.isEmpty
              ? 0.0
              : projects.fold<double>(
                  0, (sum, project) => sum + (project.progress ?? 0)
                ) / projects.length;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Cards
                Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Total Projects',
                      value: totalProjects.toString(),
                      icon: Icons.folder,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 16),
                    _buildSummaryCard(
                      title: 'Total Budget',
                      value: '\$${totalBudget.toStringAsFixed(0)}',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ],
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    _buildSummaryCard(
                      title: 'Avg. Progress',
                      value: '${(averageProgress * 100).toStringAsFixed(0)}%',
                      icon: Icons.trending_up,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 16),
                    _buildSummaryCard(
                      title: 'Completed',
                      value: completedProjects.toString(),
                      icon: Icons.check_circle,
                      color: Colors.purple,
                    ),
                  ],
                ),
                
                SizedBox(height: 32),
                
                // Project Status Chart
                _buildSectionTitle('Project Status'),
                Container(
                  height: 240,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: PieChart(
                          PieChartData(
                            pieTouchData: PieTouchData(
                              touchCallback: (FlTouchEvent event, pieTouchResponse) {
                                setState(() {
                                  if (!event.isInterestedForInteractions ||
                                      pieTouchResponse == null ||
                                      pieTouchResponse.touchedSection == null) {
                                    _touchedIndex = -1;
                                    return;
                                  }
                                  _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                                });
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: _buildPieChartSections(
                              completed: completedProjects,
                              inProgress: inProgressProjects,
                              notStarted: notStartedProjects,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 24),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildLegendItem('Completed', Colors.green),
                          SizedBox(height: 16),
                          _buildLegendItem('In Progress', Colors.orange),
                          SizedBox(height: 16),
                          _buildLegendItem('Not Started', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Room Distribution
                _buildSectionTitle('Room Distribution'),
                Container(
                  height: 240,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: roomDistribution.entries
                          .map((e) => e.value.toDouble())
                          .reduce((a, b) => a > b ? a : b) * 1.2,
                      barTouchData: BarTouchData(
                        enabled: true,
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value >= roomDistribution.length || value < 0) {
                                return const SizedBox.shrink();
                              }
                              final room = roomDistribution.keys.elementAt(value.toInt());
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  _shortenRoomName(room),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: roomDistribution.entries.map((entry) {
                        final index = roomDistribution.keys.toList().indexOf(entry.key);
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: entry.value.toDouble(),
                              color: _getColorForRoom(entry.key),
                              width: 22,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(6),
                                topRight: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                SizedBox(height: 32),
                
                // Recent Projects
                _buildSectionTitle('Recent Projects'),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: projects.length > 3 ? 3 : projects.length,
                  itemBuilder: (context, index) {
                    final project = projects[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      child: ListTile(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: NetworkImage(
                                project.imageUrl ?? Constants.placeholderImage,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        title: Text(
                          project.name ?? 'Untitled Project',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Text(project.room ?? 'Unknown'),
                            SizedBox(height: 4),
                            LinearProgressIndicator(
                              value: project.progress ?? 0,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                _getProgressColor(project.progress ?? 0),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${((project.progress ?? 0) * 100).toInt()}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getProgressColor(project.progress ?? 0),
                          ),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/project_details',
                            arguments: project,
                          );
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections({
    required int completed,
    required int inProgress,
    required int notStarted,
  }) {
    return [
      _buildPieChartSection(
        title: 'Completed',
        value: completed,
        color: Colors.green,
        index: 0,
      ),
      _buildPieChartSection(
        title: 'In Progress',
        value: inProgress,
        color: Colors.orange,
        index: 1,
      ),
      _buildPieChartSection(
        title: 'Not Started',
        value: notStarted,
        color: Colors.red,
        index: 2,
      ),
    ];
  }

  PieChartSectionData _buildPieChartSection({
    required String title,
    required int value,
    required Color color,
    required int index,
  }) {
    final isTouched = index == _touchedIndex;
    final double fontSize = isTouched ? 18 : 14;
    final double radius = isTouched ? 60 : 50;
    
    return PieChartSectionData(
      color: color,
      value: value.toDouble(),
      title: value.toString(),
      radius: radius,
      titleStyle: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
        SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _shortenRoomName(String room) {
    if (room.length <= 6) return room;
    
    final words = room.split(' ');
    if (words.length <= 1) return room.substring(0, 6);
    
    return words.map((word) => word[0]).join('');
  }

  Color _getColorForRoom(String room) {
    final colors = {
      'Living Room': Colors.blue,
      'Bedroom': Colors.purple,
      'Kitchen': Colors.orange,
      'Bathroom': Colors.teal,
      'Office': Colors.indigo,
      'Dining Room': Colors.amber,
      'Outdoor': Colors.green,
      'Other': Colors.grey,
    };
    
    return colors[room] ?? Colors.blueGrey;
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.75) return Colors.green;
    if (progress >= 0.25) return Colors.orange;
    return Colors.red;
  }
} 
