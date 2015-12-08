class NameAndNumber
{
  String m_name;
  int m_number;

  NameAndNumber(String name, int number)
  {
    m_name = name;
    m_number = number;
  }
}

class NameAndNumberComparator implements Comparator, Serializable
{
  Map m_map;

  NameAndNumberComparator(Map map)
  {
    m_map = map;
  }

  //@Override
  public int compare(Object o1, Object o2)
  {
    // Get values associated to the keys to compare
    NameAndNumber nan1 = (NameAndNumber) m_map.get(o1);
    NameAndNumber nan2 = (NameAndNumber) m_map.get(o2);
    // Sort by descending order
    return nan2.m_number - nan1.m_number;
  }
}